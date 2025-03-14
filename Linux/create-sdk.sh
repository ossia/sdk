#!/bin/bash -eux
# export DOCKER_BUILDKIT=1
# docker rmi ossia/score-sdk-base
docker build --no-cache --pull --squash --compress --force-rm -t ossia/score-sdk-base -f Dockerfile.centos .

mkdir -p /tmp/image
mkdir -p /tmp/image/ossia-sdk
cp -rf * /tmp/image/
cp -rf ../common/* /tmp/image/common/

docker run --rm -it \
           -v "/tmp/image/common:/common" \
           -v "/tmp/image:/image" \
           -v "/opt/ossia-sdk:/opt/ossia-sdk" \
           -w="/image" \
           ossia/score-sdk-base \
           /bin/bash /image/build-all-release.sh

tar caf sdk-linux.tar.xz /opt/ossia-sdk
