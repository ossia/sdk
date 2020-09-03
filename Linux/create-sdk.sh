#!/bin/bash
docker rmi ossia/score-sdk-build
docker build -t ossia/score-sdk-build -f Dockerfile.centos . 
docker rm compress_sdk
docker run --name compress_sdk -it ossia/score-sdk-build:latest tar caf score-sdk.tar.xz /opt/score-sdk
docker cp compress_sdk:/score-sdk.tar.xz ./score-sdk-linux-llvm.tar.xz
