#!/bin/bash

source ./common.sh

if [[ ! -d ffmpeg-4.2 ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-4.2.tar.bz2
  gtar xaf ffmpeg-4.2.tar.bz2
fi

mkdir ffmpeg-build
cd ffmpeg-build

xcrun ../ffmpeg-4.2/configure \
    --arch=x86_64 --cpu=x86_64 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
 	--disable-network --disable-iconv \
 	--enable-protocols  --disable-lzma \
 	--prefix=$INSTALL_PREFIX/ffmpeg \
        --cc="$CC" --cxx="$CXX" \
 	--extra-cflags="-mmacosx-version-min=$MACOS_VERSION"

xcrun make -j$NPROC
xcrun make install
