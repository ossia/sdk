#!/bin/bash

source ./common.sh
VERSION=4.3.1

if [[ ! -d ffmpeg-$VERSION ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  gtar xaf ffmpeg-$VERSION.tar.bz2
fi

mkdir ffmpeg-build
cd ffmpeg-build

xcrun ../ffmpeg-$VERSION/configure \
    --arch=x86_64 --cpu=x86_64 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-network --disable-iconv --disable-libxcb \
 	--enable-protocols --disable-lzma \
 	--prefix=$INSTALL_PREFIX/ffmpeg \
        --cc="$CC" --cxx="$CXX" \
 	--extra-cflags="$CFLAGS"

xcrun make -j$NPROC
xcrun make install
