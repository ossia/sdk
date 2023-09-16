#!/bin/bash
# export DOCKER_BUILDKIT=1
docker rmi ossia/score-sdk-rpi
docker build --squash --compress --force-rm -t ossia/score-sdk-rpi -f Dockerfile .

mkdir -p /tmp/image
mkdir -p /tmp/image/ossia-sdk-rpi
cp -rf * /tmp/image/

docker run --rm -it \
           -v "/tmp/image:/image" \
           -v "/opt/ossia-sdk-rpi:/opt/ossia-sdk-rpi" \
           -w="/image" \
           ossia/score-sdk-rpi \
           /bin/bash /image/build-all.sh

tar caf score-sdk-linux-rpi.tar.xz /opt/ossia-sdk-rpi
