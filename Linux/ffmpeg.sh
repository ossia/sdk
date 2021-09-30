#!/bin/bash

source ./common.sh
VERSION=snapshot

if [[ ! -d ffmpeg-$VERSION ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  gtar xaf ffmpeg-$VERSION.tar.bz2
fi

mkdir ffmpeg-build
cd ffmpeg-build

 ../ffmpeg-$VERSION/configure \
    --arch=x86_64 --cpu=x86_64 \
        --enable-pic \
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
