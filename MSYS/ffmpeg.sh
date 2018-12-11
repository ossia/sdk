#!/bin/bash

source ./common.sh

wget -nv https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2
tar xaf ffmpeg-4.1.tar.bz2

mkdir ffmpeg-build
cd ffmpeg-build

 ../ffmpeg-4.1/configure \
    --arch=x86_64 --cpu=x86_64 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
 	--disable-network --disable-iconv \
 	--enable-protocols  --disable-lzma \
 	--prefix=$INSTALL_PREFIX/ffmpeg 

 make -j$NPROC
 make install
