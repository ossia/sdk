#!/bin/bash

source ./common.sh

if [[ ! -d ffmpeg-4.2 ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-4.2.tar.xz
  tar -xaf ffmpeg-4.2.tar.xz
fi

mkdir ffmpeg-build
cd ffmpeg-build

 ../ffmpeg-4.2/configure \
        --arch=x86_64 --cpu=x86_64 \
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
cd ..
