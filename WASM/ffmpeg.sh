#!/bin/bash

source ./common.sh
VERSION=snapshot

if [[ ! -d ffmpeg ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  tar xaf ffmpeg-$VERSION.tar.bz2
fi

mkdir  -p ffmpeg-build
cd ffmpeg-build


# configure FFMpeg with Emscripten
ARGS=(
  --target-os=none        # use none to prevent any os specific configurations
  --arch=x86_32           # use x86_32 to achieve minimal architectural optimization
  --enable-cross-compile  # enable cross compile
  --disable-x86asm        # disable x86 asm
  --disable-inline-asm    # disable inline asm
  --disable-doc 
  --disable-ffmpeg 
  --disable-ffplay
  --disable-ffprobe
  --disable-debug 
  --pkg-config-flags="--static" 
  --enable-gpl --enable-version3 
  --disable-openssl 
  --disable-securetransport 
  --disable-network 
  --disable-iconv 
  --enable-protocols 
  --disable-lzma 
  --nm="llvm-nm -g"
  --ar=emar
  --ranlib=llvm-ranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CFLAGS"
  --extra-ldflags="$LDFLAGS"
  --prefix=$INSTALL_PREFIX/ffmpeg
)

emconfigure ../ffmpeg/configure "${ARGS[@]}"
emmake make -j$NPROC
emmake make install
