FROM rockylinux:9

# Install packages we will need in our 'builder' OS
RUN yum -y update && \
    yum install -y \
        wget \
        yum-utils\
        pigz \
        cpio \
        openssh-server \
        && yum clean all -y
