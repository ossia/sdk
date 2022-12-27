#!/bin/bash

source common.sh
sudo docker build  --squash --compress --force-rm  -f Dockerfile.debian -t ossia/score-rpi .

mkdir -p $SDK_INSTALL_ROOT
cd $SDK_INSTALL_ROOT && \
    mkdir pi && \
    mkdir pi/build && \
    mkdir pi/tools && \
    mkdir pi/sysroot && \
    mkdir pi/sysroot/usr && \
    mkdir pi/sysroot/opt && \
    chown -R 1000:1000 pi

sudo docker run -v $SDK_INSTALL_ROOT:$SDK_INSTALL_ROOT ossia/score-rpi /bin/bash 'copy_sysroot.sh'

cd $SDK_INSTALL_ROOT/pi

wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
sudo python sysroot-relativelinks.py sysroot
