#!/bin/bash -eux
#export DOCKER_BUILDKIT=1
# docker rmi ossia/score-sdk-base
# docker build --no-cache --pull --squash --compress --force-rm -t ossia/score-sdk-base -f Dockerfile.centos .

mkdir -p /tmp/image
mkdir -p /opt/ossia-sdk-$CPU_ARCH
cp -rf * /tmp/image/
cp -rf ../common/* /tmp/image/common/

docker run --rm -it \
-e CPU_ARCH="$CPU_ARCH" \
-v "/tmp/image/common:/common" \
-v "/tmp/image:/image" \
-v "/opt/ossia-sdk-$CPU_ARCH:/opt/ossia-sdk-$CPU_ARCH" \
-w="/image" \
ossia/score-sdk-base \
/bin/bash /image/build-all-release.sh

tar caf sdk-linux.tar.xz /opt/ossia-sdk-$CPU_ARCH
