#!/bin/bash

source ./common.sh
VERSION=snapshot

if [[ ! -d ffmpeg-$VERSION ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  tar xaf ffmpeg-$VERSION.tar.bz2
fi

mkdir ffmpeg-build
cd ffmpeg-build



export PATH=$PATH:$CROSS_COMPILER_LOCATION/bin
export CCPREFIX=$CROSS_COMPILER_LOCATION/bin/arm-linux-gnueabihf-

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
