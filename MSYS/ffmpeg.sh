#!/bin/bash -eu

source ./common.sh
source ../common/clone-ffmpeg.sh
source ../common/ffmpeg-features.sh

(
cd ffmpeg-$FFMPEG_VERSION
rm -f VERSION
export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export CFLAGS="-isystem $INSTALL_PREFIX_CMAKE/sysroot/include $CFLAGS $ARCHFLAGS"
export LDFLAGS="-L$INSTALL_PREFIX_CMAKE/sysroot/lib $LDFLAGS"

# Feature flags live in common/ffmpeg-features{,.mingw}; only what varies per
# build is here. Unquoted $(...) on purpose -- word-split, like $(cat qtfeatures).
./configure \
  $(ffmpeg_features mingw $SDK_ARCH) \
  --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" \
  --pkg-config="pkg-config" \
  --extra-cflags=" $CFLAGS " \
  --extra-ldflags=" $LDFLAGS " \
  --extra-libs=" $LDFLAGS " \
  --prefix="$INSTALL_PREFIX/ffmpeg" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

$MAKE V=1 -j1
$MAKE install
)
