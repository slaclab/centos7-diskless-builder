# CentOS 7 Diskless Image Generation

## Description

This repository contains the code use to generate CentOS 7 diskless images, which can be boot using IPXE.

## Pre-requisites

You need to run this script in a host with the docker engine installed in it.

## How to generate the images

In order to generate the CentOS 7 diskless images, you just need to run the [generate.sh](generate.sh) script. The resulting files will be located in the [output](output) directory.

The images are generated using a Docker container based on CentOS 7. The docker image generation files are provided in the [docker](docker) directory. So, the script first generates the docker images, and the builds the image inside that container.
