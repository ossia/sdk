#!/bin/bash

source ./common.sh
source ../common/clone-ffmpeg.sh

(
cd ffmpeg

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export CLFAGS="-isystem $INSTALL_PREFIX/sysroot/include $CFLAGS"
export LDFLAGS="-L$INSTALL_PREFIX/sysroot/lib $LDFLAGS"
./configure \
    --arch=x86_64 --cpu=x86-64 \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
	--enable-dxva2 --enable-d3d11va \
 	--pkg-config-flags="--static" \
    --pkg-config="pkg-config" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
	--enable-libsnappy \
 	--disable-network --disable-iconv \
 	--enable-protocols \
	--extra-cflags=" $CFLAGS " \
	--extra-ldflags=" $LDFLAGS " \
	--extra-libs=" $LDFLAGS " \
 	--prefix="$INSTALL_PREFIX/ffmpeg" 

$MAKE V=1 -j1
$MAKE install
)
