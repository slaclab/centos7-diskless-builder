#!/usr/bin/env bash

docker container run -ti --rm \
	--mount src=${PWD}/output,target=/output,type=bind \
    --mount src=${PWD}/scripts,target=/scripts,type=bind \
    --mount src=${PWD}/custom_files,target=/custom_files,type=bind \
    centos7-builder \
    /scripts/generate-image.sh
