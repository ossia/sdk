#!/bin/bash

source /image/config.sh
## FFMPEG
apt -y install  nasm
wget -nv https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2
tar -xaf ffmpeg-4.1.tar.bz2
cd ffmpeg-4.1
export CFLAGS="-O3 -mfpu=neon-vfpv4"
./configure --arch=armv7-a --cpu=cortex-a7 --disable-doc --disable-ffmpeg --disable-ffplay --disable-debug --prefix=/usr/local --pkg-config-flags="--static" --enable-gpl --enable-version3 --disable-openssl --disable-securetransport --disable-videotoolbox --disable-network --disable-iconv --disable-lzma
make -j$(nproc)
make install
cd ..
