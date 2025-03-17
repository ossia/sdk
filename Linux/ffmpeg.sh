#!/bin/bash -eu

source ./common.sh clang
source ../common/clone-ffmpeg.sh

if [[ -f $INSTALL_PREFIX/ffmpeg/bin/ffprobe ]]; then
  exit 0
fi

mkdir -p ffmpeg-build
cd ffmpeg-build

declare -a FFMPEG_COMMON_FLAGS=(
  --cpu=$GCC_CPU
  --enable-pic
  --enable-gpl
  --enable-version3
  --disable-doc
  --disable-ffmpeg
  --disable-ffplay
  --disable-debug
  --disable-autodetect # not present on aarch64
  --disable-openssl
  --disable-securetransport
  --disable-network
  --disable-iconv
  --disable-libxcb
  --disable-libxcb-shm
  --disable-libxcb-xfixes
  --disable-alsa
  --enable-protocols
  --disable-lzma
  --extra-cflags="$CFLAGS -fPIC"
  --cc="$CC"
  --cxx="$CXX"
  --prefix=$INSTALL_PREFIX/ffmpeg
)

# FIXME apply librelec patches:
# https://github.com/LibreELEC/LibreELEC.tv/blob/master/packages/multimedia/ffmpeg/package.mk

declare -a FFMPEG_AARCH64_FLAGS=(
  --arch=aarch64
  --enable-libv4l2
  --enable-v4l2-m2m
  --enable-sand
  --enable-v4l2-request
  --enable-libdrm
  --enable-libudev
)
declare -a FFMPEG_X86_64_FLAGS=(
  --arch=x86-64-v3
  --disable-libv4l2
  --enable-indev=v4l2
)
declare -n FFMPEG_ARCH_FLAGS=FFMPEG_${ARCH_VARNAME}_FLAGS

# --enable-opencl --enable-libmfx --enable-nvenc --enable-cuda --enable-vaapi --enable-vdpau \

../ffmpeg-$FFMPEG_VERSION/configure  "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_ARCH_FLAGS[@]}"

make -j$NPROC
make install
