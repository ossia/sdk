#!/bin/bash

source ./common.sh gcc
source ../common/clone-ffmpeg.sh raspi

mkdir -p ffmpeg-build
cd ffmpeg-build

export PATH=$PATH:$CROSS_COMPILER_LOCATION/bin
export PKG_CONFIG_PATH="$SYSROOT/usr/lib/aarch64-linux-gnu/pkgconfig"
export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/aarch64-linux-gnu/pkgconfig:$SYSROOT/usr/lib/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/share/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/aarch64-rpi3-linux-gnu/pkgconfig"

export CLFAGS="-isystem $INSTALL_PREFIX/sysroot/include $CFLAGS"
export LDFLAGS="-L$INSTALL_PREFIX/sysroot/lib $LDFLAGS"
../ffmpeg/configure \
    --enable-cross-compile \
    --cross-prefix=${CCPREFIX} \
    --sysroot=${SYSROOT} \
    --target-os=linux \
    --arch=$FFMPEG_ARCH --cpu=cortex-a72 \
    --disable-doc --disable-ffmpeg --disable-ffplay \
    --disable-debug \
    --enable-sand --enable-v4l2-request --enable-libdrm --enable-libudev \
    --enable-libv4l2 --enable-v4l2-m2m \
    --disable-alsa --disable-libxcb \
    --pkg-config-flags="--static" \
    --pkg-config="pkg-config" \
    --enable-gpl --enable-version3 \
    --disable-openssl --disable-securetransport \
    --disable-network --disable-iconv \
    --enable-protocols --disable-lzma \
    --prefix=$INSTALL_PREFIX/ffmpeg \
    --extra-cflags="$CFLAGS -fPIC" --extra-libs=-lpthread || exit 1

#     --enable-libv4l2 \

make -j$NPROC
make install
