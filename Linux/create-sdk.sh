#!/bin/bash
sudo docker rmi ossia/score-sdk-build
sudo docker build -t ossia/score-sdk-build -f Dockerfile.centos . 
sudo docker rm compress_sdk
sudo docker run --name compress_sdk -it ossia/score-sdk-build:latest tar caf score-sdk.tar.xz /opt/score-sdk
sudo docker cp compress_sdk:/score-sdk.tar.xz ./score-sdk-linux-llvm.tar.xz
