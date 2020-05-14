#!/bin/bash

if [[ ! -f ffmpeg-4.2.2.tar.bz2 ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2
  tar xaf ffmpeg-4.2.2.tar.bz2
fi

export PATH="/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.25.28610/bin/Hostx64/x64:$PATH"
mkdir ffmpeg-build
cd ffmpeg-build

 ../ffmpeg-4.2.2/configure \
    --arch=x86_64 --cpu=x86_64 --toolchain=msvc --target-os=win64 \
    --enable-asm --enable-yasm \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
 	--disable-network --disable-iconv \
 	--enable-protocols  --disable-lzma \
 	--prefix=/c/score-sdk-msvc/ffmpeg 

 make -j$NPROC
 make install
