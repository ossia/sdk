#!/bin/bash -eu

source ./common.sh
source ../common/clone-ffmpeg.sh

mkdir ffmpeg-build
cd ffmpeg-build

if [[ "$MACOS_ARCH" == "arm64" ]]; then
  export FFMPEG_CPU_OPTIONS=(
  )
else
  export FFMPEG_CPU_OPTIONS=(
    --arch=x86_64 --cpu=$CPU_TARGET
  )
fi
xcrun ../ffmpeg/configure \
    "${FFMPEG_CPU_OPTIONS[@]}" \
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

xcrun make -j$NPROC V=1 VERBOSE=1
xcrun make install
