FROM centos:7

# Install packages we will need in our 'builder' OS
RUN yum -y update && \
    yum install -y \
        wget \
        yumdownloader \
        pigz \
	openssh-server \
    && yum clean all -y
