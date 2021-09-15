#!/usr/bin/env bash

# Get the centos-release RPM
yumdownloader centos-release

# Prepare target root directory
mkdir /diskless-root

# centos-release contains things like the yum configs, and is necessary to bootstrap the system
rpm --root=/diskless-root -ivh --nodeps centos-release-7-9.2009.1.el7.centos.x86_64.rpm

# Install packages in our target root directory
yum --installroot=/diskless-root -y install \
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
cd /diskless-root

# Add SLAC custom files
cp /custom_files/slac.sh etc/profile.d/
mkdir root/scripts
cp /custom_files/run_bootfile.sh root/scripts
cp /custom_files/run_bootfile.service root/scripts

# Set some important configuration
ln -s ./sbin/init ./init
echo NETWORKING=yes > etc/sysconfig/network
#echo /afs/slac.stanford.edu/g/lcls/epics/iocCommon/cpu-b084-sp16/startup.cmd > etc/bootfile

# For afs
mkdir -p afs/slac.stanford.edu
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
        pwconv && \
        passwd -d root && \
        groupadd lcls && \
        groupmod -g 2211 lcls && \
        useradd -g lcls -d /home/laci -m laci && \
        usermod -u 8412 laci && \
        passwd -d laci && \
        systemctl enable /root/scripts/run_bootfile.service && \
        exit \
    '

# Generate the cpio image
find | cpio -ocv | pigz -9 > /output/diskless.cpio.gz

# Copy the kernel image
cp boot/vmlinuz-3.10.0-1160.42.2.el7.x86_64 /output/
