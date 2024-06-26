# CentOS 7 Builder Docker Image

## Description

This directory contains the Dockerfile used to generate a CentOS 7 docker image, which we will use as a *host* to build out root image.

## Build the Docker image

To build the image you can run this command:
```bash
docker image build -t rl9-builder .
```

A script `build.sh` is provided in this directory which you can use to run the command above.

## Run the Docker container

After building the docker image, you can run the container with this command:
```bash
docker run -ti --rm rl9-builder
```

You will normally need to mount a local directory inside the container in order to write the generated images, so you will need use the `--mount` argument as well.
