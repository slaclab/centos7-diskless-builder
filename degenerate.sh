#!/usr/bin/env bash

# remove everything so you can start fresh

rm -rf output
mkdir output
docker volume rm rl9-builder
docker image rm rl9-builder
