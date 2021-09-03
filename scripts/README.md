# Image generation scripts

## Description

This directory contains scripts that are use to generate the diskless CentOS 7 image.

## Script Description

| Script             | Description
|--------------------|-------------
| generate-image.sh  | Generates the local target root image, and generates a CPIO image from it. It then copies the resulting CPIO and kernel image into the `/output` directory.
