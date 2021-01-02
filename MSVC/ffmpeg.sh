#!/bin/bash

export VERSION=4.3.1
if [[ ! -f ffmpeg-$VERSION.tar.bz2 ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  tar xaf ffmpeg-$VERSION.tar.bz2
fi


shopt -s nullglob

msvc_version=$(ls "/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/")
msvc_path="/c/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/$msvc_version/bin/Hostx64/x64"

export PATH="$msvc_path:$PATH"

rm -rf ffmpeg-build
mkdir -p ffmpeg-build
cd ffmpeg-build

 ../ffmpeg-$VERSION/configure \
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
 	--prefix=/c/score-sdk-msvc-release/ffmpeg 

 make -j$NPROC
 make install
