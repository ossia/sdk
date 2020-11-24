#!/bin/bash
# export DOCKER_BUILDKIT=1
docker rmi ossia/score-sdk-base
docker build --squash --compress --force-rm -t ossia/score-sdk-base -f Dockerfile.centos .

mkdir -p /tmp/image
mkdir -p /tmp/image/score-sdk
cp -rf * /tmp/image/

docker run --rm -it \
           -v "/tmp/image:/image" \
           -v "/tmp/image/score-sdk:/opt/score-sdk" \
           -w="/image" \
           ossia/score-sdk-base \
           /bin/bash /image/build-all.sh

# docker rmi ossia/score-sdk-build
# docker run -t ossia/score-sdk-build -f Dockerfile.centos -v /tmp/image:/image . 
# docker rm compress_sdk
# docker run --name compress_sdk -it ossia/score-sdk-build:latest tar caf score-sdk.tar.xz /opt/score-sdk
# docker cp compress_sdk:/score-sdk.tar.xz ./score-sdk-linux-llvm.tar.xz
