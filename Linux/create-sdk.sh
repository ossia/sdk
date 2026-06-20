#!/bin/bash -eux
#export DOCKER_BUILDKIT=1
docker rmi ossia/score-sdk-base || true
# NB: --squash needs a daemon with experimental features and is rejected by
# modern Docker/BuildKit, so it is not used here (it only shrank the base image,
# not the produced SDK).
docker build --no-cache --pull --compress --force-rm -t ossia/score-sdk-base -f Dockerfile.centos .

mkdir -p /tmp/image
mkdir -p /opt/ossia-sdk-$CPU_ARCH
cp -rf * /tmp/image/
cp -rf ../common/* /tmp/image/common/

# No -it: must stay non-interactive so it works under CI.
docker run --rm \
-e CPU_ARCH="$CPU_ARCH" \
-v "/tmp/image/common:/common" \
-v "/tmp/image:/image" \
-v "/opt/ossia-sdk-$CPU_ARCH:/opt/ossia-sdk-$CPU_ARCH" \
-w="/image" \
ossia/score-sdk-base \
/bin/bash /image/build-all-release.sh

tar caf sdk-linux-$CPU_ARCH.tar.xz /opt/ossia-sdk-$CPU_ARCH
