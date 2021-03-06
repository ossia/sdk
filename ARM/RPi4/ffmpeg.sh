#!/bin/bash

source ./common.sh
VERSION=4.3.1

if [[ ! -d ffmpeg-$VERSION ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  tar xaf ffmpeg-$VERSION.tar.bz2
fi

mkdir ffmpeg-build
cd ffmpeg-build



export PATH=$PATH:/opt/ossia-sdk-rpi/cross-pi-gcc-10.2.0-2/bin
export CCPREFIX=/opt/ossia-sdk-rpi/cross-pi-gcc-10.2.0-2/bin/arm-linux-gnueabihf-

../ffmpeg-$VERSION/configure \
    --enable-cross-compile \
	--cross-prefix=${CCPREFIX} --target-os=linux \
    --arch=arm --cpu=cortex-a72 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-network --disable-iconv \
 	--enable-protocols --disable-lzma \
 	--prefix=$INSTALL_PREFIX/ffmpeg \
 	--extra-cflags="$CFLAGS"

make -j$NPROC
make install
