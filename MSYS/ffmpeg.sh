#!/bin/bash -eu

source ./common.sh
source ../common/clone-ffmpeg.sh

(
cd ffmpeg-$FFMPEG_VERSION
rm -f VERSION
export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export CFLAGS="-isystem $INSTALL_PREFIX_CMAKE/sysroot/include $CFLAGS $ARCHFLAGS"
export LDFLAGS="-L$INSTALL_PREFIX_CMAKE/sysroot/lib $LDFLAGS"

echo "::group::snappy-c.h location probe"
echo "INSTALL_PREFIX=$INSTALL_PREFIX  INSTALL_PREFIX_CMAKE=$INSTALL_PREFIX_CMAKE"
echo "expected: $INSTALL_PREFIX_CMAKE/sysroot/include/snappy-c.h"
ls -la "$INSTALL_PREFIX/sysroot/include/snappy-c.h" 2>&1 || true
echo "-- actual locations under the drive: --"
find /c -maxdepth 4 -name 'snappy-c.h' 2>/dev/null || true
echo "::endgroup::"
./configure \
 	--cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
	--enable-dxva2 \
	--enable-d3d11va \
	--enable-d3d12va \
 	--pkg-config-flags="--static" \
        --pkg-config="pkg-config" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
	--enable-libsnappy \
 	--disable-network --disable-iconv  --disable-response-files \
 	--enable-protocols \
	--extra-cflags=" $CFLAGS " \
	--extra-ldflags=" $LDFLAGS " \
	--extra-libs=" $LDFLAGS " \
 	--prefix="$INSTALL_PREFIX/ffmpeg" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

# 
$MAKE V=1 -j1
$MAKE install
)
