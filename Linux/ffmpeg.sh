#!/bin/bash -eu

source ./common.sh clang
source ../common/clone-ffmpeg.sh

mkdir -p ffmpeg-build
cd ffmpeg-build

# FIXME need to remove the check for linux_videoio_h for some reason in configure

# --enable-opencl --enable-libmfx --enable-nvenc --enable-cuda --enable-vaapi --enable-vdpau \
../ffmpeg-$FFMPEG_VERSION/configure \
    --arch=x86-64-v3 --cpu=x86-64-v3 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
	--disable-autodetect \
    --enable-pic \
 	--enable-gpl --enable-version3 \
	--disable-libv4l2 \
 	--disable-openssl --disable-securetransport \
 	--disable-network --disable-iconv \
    --disable-libxcb --disable-libxcb-shm --disable-libxcb-xfixes \
    --disable-alsa \
	--enable-indev=v4l2 \
 	--enable-protocols --disable-lzma \
 	--prefix=$INSTALL_PREFIX/ffmpeg \
	--cc="$CC" --cxx="$CXX" \
 	--extra-cflags="$CFLAGS -fPIC"

make -j$NPROC

make install
