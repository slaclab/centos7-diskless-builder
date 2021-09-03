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
    vim

# Go to our target root directory
cd /diskless-root

# Add SLAC custom files
cp /custom_files/slac.sh etc/profile.d/

# Set some important configuration
ln -s ./sbin/init ./init
echo NETWORKING=yes > etc/sysconfig/network

# chroot and set the root password to "root", and create the laci account
chroot . \
    bash -c '\
        pwconv && \
        echo "root:root" | chpasswd && \
        useradd -d /home/laci -m laci && \
        usermod -aG laci laci && \
        passwd -d laci && \
        exit \
    '

# Generate the cpio image
find | cpio -ocv | pigz -9 > /output/diskless.cpio.gz

# Copy the kernel image
cp boot/vmlinuz-3.10.0-1160.41.1.el7.x86_64 /output/
