#!/usr/bin/env bash

show_usage() {
    echo "Usage: $0 [--prod] [-h/--help] [-s/--skip-output]"
    echo "Builds the CentOS image inside Docker and outputs"
    echo "the result to the binded output directory."
    echo ""
    echo "Installs the CentOs rootfs, installs packages in the created rootfs, creates"
    echo "user groups and accounts, copy files from the external world to the rootfs,"
    echo "configure services, and export images."
    echo "If --prod is not passed as argument, the image will be built for Dev environment."
    echo ""
    echo "Optional arguments:"
    echo "  -h, --help                  Show this help message and exit"
    echo "  --prod                      Builds image for the production environment"
    echo "  -s, --skip-output           Only builds the image but don't output products. Nice for testing."
    echo ""
    exit
}

prod_flag=
skip_output_flag=

while [ -n "$1" ]; do
    case "$1" in
        -h | --help)
            # Show this help message and exit
            show_usage
            exit
            ;;
        --prod)
            # Build for prod environment
            prod_flag=1
            ;;
        -s | --skip-output)
            skip_output_flag=1
            ;;
        *)
            # Reject invalid flags
            echo "Error: invalid option $1"
            show_usage
            exit
    esac
    shift
done


# Verify if Docker volume was created. If not, exit script.
if [ ! -d "/centos7-builder" ]; then
  echo "centos7-builder Docker volume not found. Configure the container with this volume."
  exit 2
fi

# Create diskless-root directory inside the Docker volume, if needed
if [ ! -d "/centos7-builder/diskless-root" ]; then
  mkdir /centos7-builder/diskless-root
fi

cd /centos7-builder

# Download centos-release, if needed
if [ ! -f "centos-release-7-9.2009.1.el7.centos.x86_64.rpm" ]; then
  # Get the centos-release RPM
  yumdownloader centos-release
fi

# centos-release contains things like the yum configs, and is necessary to bootstrap the system
rpm --root=/centos7-builder/diskless-root -ivh --nodeps centos-release-7-9.2009.1.el7.centos.x86_64.rpm

# Install packages in our target root directory
yum --installroot=/centos7-builder/diskless-root -y install \
    basesystem \
    filesystem \
    bash \
    kernel \
    passwd \
    openssh-server \
    openssh-clients \
    nfs-utils \
    dhcp \
    dhclient \
    net-tools \
    ethtool \
    pciutils \
    usbutils \
    vim \
    NetworkManager \
    screen \
    ipmitool \
    gcc

# Go to our target root directory
cd diskless-root

# Add SLAC custom files and force copy, even if it exists
cp -r /custom_files/slac.sh etc/profile.d/
if [ ! -d "root/scripts" ]; then
  mkdir root/scripts
fi
cp -r /custom_files/run_bootfile_dev.sh root/scripts
cp -r /custom_files/run_bootfile_prod.sh root/scripts
cp -r /custom_files/create-users.sh root/scripts
if [ -n "$prod_flag" ]; then
  cp -r /custom_files/run_bootfile_prod.service usr/lib/systemd/system/run_bootfile.service
else
  cp -r /custom_files/run_bootfile_dev.service usr/lib/systemd/system/run_bootfile.service
fi
cp -r /custom_files/epics.conf etc/security/limits.d
cp -r /custom_files/90-nproc.conf etc/security/limits.d

# Set some important configiuration
if [ ! -e "init" ]; then
  ln -s ./sbin/init ./init
fi
echo NETWORKING=yes > etc/sysconfig/network

# For AFS in dev and NFS in prod
if [ -n "$prod_flag" ]; then
  # Delete usr/local/ contents as prod uses it as mounting point
  # and CentOs 7 has it only with empty directories.
  rm -rf usr/local/*
  if [ -d "afs/slac.stanford.edu" ]; then
    rm -rf afs
  fi
  echo "mccfs2:/export/mccfs/usr/local /usr/local nfs ro,nolock,noac,soft 0 0" > etc/fstab
else
  if [ ! -d "afs/slac.stanford.edu" ]; then
    mkdir -p afs/slac.stanford.edu
    #echo "afsnfs:/afs/slac.stanford.edu /afs/slac.stanford.edu nfs ro,nolock,noac,soft 0 0" > etc/fstab
    echo "afsnfs:/afs/slac.stanford.edu /afs/slac.stanford.edu nfs _netdev,auto,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14 0 0" > etc/fstab
  fi
fi

# Allow laci to access without password and blocks root ssh login
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/" etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" etc/ssh/sshd_config

# Increasing limit priorities for EPICS IOCs to set SCHED_FIFO properly
sed -i "s/#DefaultLimitMEMLOCK=/DefaultLimitMEMLOCK=infinity/g" etc/systemd/system.conf
sed -i "s/#DefaultLimitRTPRIO=/DefaultLimitRTPRIO=infinity/g" etc/systemd/system.conf
sed -i "s/#DefaultLimitMEMLOCK=/DefaultLimitMEMLOCK=infinity/g" etc/systemd/user.conf
sed -i "s/#DefaultLimitRTPRIO=/DefaultLimitRTPRIO=infinity/g" etc/systemd/user.conf

# chroot, set a blank password to root, and create the laci account. laci
# account must have UID 8412 and be part of an lcls group with GID 2211.
# The IDs are important for accessing NFS directories.
chroot . \
    bash -c '\
        /root/scripts/create-users.sh && \
        systemctl enable /usr/lib/systemd/system/run_bootfile.service && \
        exit \
    '
echo "skip-output_flag"
echo $skip_output_flag
if [ -z "$skip_output_flag" ]; then
  # Generate the cpio image. Compress with -1 equals to fastest and less compression.
  # This helps with the speed of generating the image and also uncompressing during the PXE boot.
  find | cpio -ocv | pigz -1 > /output/diskless.cpio.gz

  # Copy the kernel image
  cp boot/vmlinuz-3.10.0-1160.42.2.el7.x86_64 /output/
fi
