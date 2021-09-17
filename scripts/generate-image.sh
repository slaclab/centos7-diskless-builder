#!/usr/bin/env bash

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
    gcc \
    rtkit

# Go to our target root directory
cd diskless-root

# Add SLAC custom files and force copy, even if it exists
cp -r /custom_files/slac.sh etc/profile.d/
if [ ! -d "root/scripts" ]; then
  mkdir root/scripts
fi
cp -r /custom_files/run_bootfile.sh root/scripts
cp -r /custom_files/create-users.sh root/scripts
cp -r /custom_files/run_bootfile.service usr/lib/systemd/system
cp -r /custom_files/epics.conf etc/security/limits.d
cp -r /custom_files/90-nproc.conf etc/security/limits.d

# Set some important configiuration
if [ ! -e "init" ]; then
  ln -s ./sbin/init ./init
fi
echo NETWORKING=yes > etc/sysconfig/network
#echo /afs/slac.stanford.edu/g/lcls/epics/iocCommon/cpu-b084-sp16/startup.cmd > etc/bootfile

# For AFS
if [ ! -d "afs/slac.stanford.edu" ]; then
  mkdir -p afs/slac.stanford.edu
fi
#echo "afsnfs:/afs/slac.stanford.edu /afs/slac.stanford.edu nfs ro,nolock,noac,soft 0 0" > etc/fstab
echo "afsnfs:/afs/slac.stanford.edu /afs/slac.stanford.edu nfs _netdev,auto,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14 0 0" > etc/fstab

# Allow laci to access without password and blocks root ssh login
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/" etc/ssh/sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" etc/ssh/sshd_config

# chroot, set a blank password to root, and create the laci account. laci
# account must have UID 8412 and be part of an lcls group with GID 2211.
# The IDs are important for accessing NFS directories.
chroot . \
    bash -c '\
        /root/scripts/create-users.sh && \
        systemctl enable /usr/lib/systemd/system/run_bootfile.service && \
        exit \
    '

# Generate the cpio image
find | cpio -ocv | pigz -9 > /output/diskless.cpio.gz

# Copy the kernel image
cp boot/vmlinuz-3.10.0-1160.42.2.el7.x86_64 /output/
