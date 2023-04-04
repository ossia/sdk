#!/bin/bash

source ./common.sh

export VERSION=snapshot

if [[ ! -f ffmpeg-$VERSION.tar.bz2 ]]; then
  wget -nv --no-check-certificate https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  tar xaf ffmpeg-$VERSION.tar.bz2
fi

cd ffmpeg

 ./configure \
    --arch=x86_64 --cpu=x86_64 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
	--enable-dxva2 --enable-d3d11va \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
 	--disable-network --disable-iconv \
 	--enable-protocols  --disable-lzma \
 	--prefix=$INSTALL_PREFIX/ffmpeg 

 make V=1 -j1
 make install
