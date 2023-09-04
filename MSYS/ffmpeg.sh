#!/bin/bash

source ./common.sh
source ../common/clone-ffmpeg.sh

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

$MAKE V=1 -j1
$MAKE install
