#!/bin/bash
sudo docker build  --squash --compress --force-rm  -f Dockerfile.debian -t ossia/score-rpi .

mkdir -p /opt/ossia-sdk-rpi
cd /opt/ossia-sdk-rpi && \
    mkdir pi && \
    mkdir pi/build && \
    mkdir pi/tools && \
    mkdir pi/sysroot && \
    mkdir pi/sysroot/usr && \
    mkdir pi/sysroot/opt && \
    chown -R 1000:1000 pi

sudo docker run -v /opt/ossia-sdk-rpi:/opt/ossia-sdk-rpi ossia/score-rpi /bin/bash 'copy_sysroot.sh'

cd /opt/ossia-sdk-rpi/pi

wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
sudo python sysroot-relativelinks.py sysroot
