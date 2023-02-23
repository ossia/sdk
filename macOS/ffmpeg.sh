#!/bin/bash

source ./common.sh
VERSION=snapshot

if [[ ! -d ffmpeg ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  gtar xaf ffmpeg-$VERSION.tar.bz2
fi

mkdir ffmpeg-build
cd ffmpeg-build

xcrun ../ffmpeg/configure \
    --arch=x86_64 --cpu=x86_64 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
	--disable-autodetect \
	--enable-avfoundation \
	--enable-indev=avfoundation \
	--enable-videotoolbox --enable-audiotoolbox \
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
