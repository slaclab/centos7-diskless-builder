# COLD7 - CentOS 7 Light Distribution

## Description

This repository contains the code used to generate CentOS 7 diskless images, which can be boot using IPXE.

## Pre-requisites

You need to run this script in a host with the docker engine installed in it.

## How to generate the images

In order to generate the CentOS 7 diskless images, you just need to run the [generate.sh](generate.sh) script. The resulting files will be located in the [output](output) directory. generate.sh can be run using optional parameters:

If --prod is not passed as argument, the image will be built for Dev environment.

Optional arguments:
  -h, --help                  Show this help message and exit
  --prod                      Builds image for the production environment
  -s, --skip-output           Only builds the image but don't output products. Nice for testing.

The images are generated using a Docker container based on CentOS 7. The docker image generation files are provided in the [docker](docker) directory. So, the script first generates the docker images, and the builds the image inside that container.

The [login_docker.sh](login_docker.sh) script can be used to access the container after generate.sh is run. The rootfs of the COLD7 image is in /centos7-builder/diskless-root/, inside the container. 
