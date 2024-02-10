#!/usr/bin/env bash

# remove everything so you can start fresh

rm -rf output
mkdir output
docker volume rm centos7-builder
docker image rm centos7-builder
