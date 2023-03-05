#!/bin/bash
# export DOCKER_BUILDKIT=1
docker rmi ossia/score-sdk-base-debug
docker build --no-cache --pull --squash --compress --force-rm -t ossia/score-sdk-base-debug -f Dockerfile.centos .

mkdir -p /tmp/image
mkdir -p /tmp/image/ossia-sdk-debug
cp -rf * /tmp/image/

docker run --rm -it \
           -v "/tmp/image:/image" \
           -v "/opt/ossia-sdk-debug:/opt/ossia-sdk-debug" \
           -w="/image" \
           ossia/score-sdk-base-debug \
           /bin/bash /image/build-all-debug.sh

tar caf sdk-linux.tar.xz /opt/ossia-sdk-debug
