#!/bin/bash -eu

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh
source ../common/clone-ffmpeg.sh
source ../common/ffmpeg-features.sh

# media-deps.sh installs the codecs and libsrt into $INSTALL_PREFIX, openssl.sh
# into $INSTALL_PREFIX/openssl. common.sh pins PKG_CONFIG_LIBDIR at the former
# to keep Homebrew out, so extend it rather than replacing it.
export PKG_CONFIG_LIBDIR="$INSTALL_PREFIX/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib/pkgconfig"

# Feature flags live in common/ffmpeg-features{,.macos}. Unquoted on purpose:
# the output is word-split, exactly like $(cat qtfeatures) in qt.sh.
# TARGET_ARCH is arm64/x86_64; the feature-file arch layer is named aarch64.
if [[ "$TARGET_ARCH" == "arm64" ]]; then FEATURES_ARCH=aarch64; else FEATURES_ARCH=x86_64; fi
declare -a FFMPEG_COMMON_FLAGS=( $(ffmpeg_features macos $FEATURES_ARCH) )

export FFMPEG_ARM64_FLAGS=(
 --cpu=$CPU_TARGET
 --prefix=$INSTALL_PREFIX/ffmpeg
 --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC  -arch arm64 "
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -I$INSTALL_PREFIX/include"
 --extra-ldflags="$CFLAGS_NOARCH -L$INSTALL_PREFIX/lib"
)
export FFMPEG_X86_64_FLAGS=(
 --arch="x86_64"
 --prefix=$INSTALL_PREFIX/ffmpeg
 --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC  -arch x86_64 "
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -march=$CPU_TARGET -I$INSTALL_PREFIX/include"
 --extra-ldflags="$CFLAGS_NOARCH -L$INSTALL_PREFIX/lib"
)
export FFMPEG_X86_64H_FLAGS=(
 --arch="x86_64h"
 --prefix=$INSTALL_PREFIX/ffmpeg_h
 --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC  -arch x86_64h "
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -mtune=cannonlake -I$INSTALL_PREFIX/include"
 --extra-ldflags="$CFLAGS_NOARCH -L$INSTALL_PREFIX/lib"
)

if [[ "$TARGET_ARCH" == "arm64" ]]; then
  (
  rm -rf ffmpeg-build
  mkdir -p ffmpeg-build
  cd ffmpeg-build

  xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_ARM64_FLAGS[@]}" \
    || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

  xcrun make -j$NPROC V=1 VERBOSE=1
  xcrun make install
  )
else
(
  # We build ffmpeg twice, once in x86_64 and once in x86_64h and then we combine with lipo.
  # The dependency libraries are NOT built twice: ld64 links an x86_64h binary
  # against plain x86_64 archives, so media-deps.sh ships one slice (see there).
  (
  mkdir -p ffmpeg-build
  cd ffmpeg-build

  unset CFLAGS
  xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_X86_64_FLAGS[@]}" \
    || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

  xcrun make -j$NPROC V=1 VERBOSE=1
  xcrun make install
  )

  (
  mkdir -p ffmpeg-build_h
  cd ffmpeg-build_h

  unset CFLAGS
  xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_X86_64H_FLAGS[@]}" \
    || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

  xcrun make -j$NPROC V=1 VERBOSE=1
  xcrun make install
  )

  cp -rf $INSTALL_PREFIX/ffmpeg/lib lib_n
  cp -rf $INSTALL_PREFIX/ffmpeg_h/lib lib_h

  for file in libavcodec.a libavdevice.a libavfilter.a libavformat.a libavutil.a libswresample.a libswscale.a; do
    lipo lib_n/$file lib_h/$file -create -output $INSTALL_PREFIX/ffmpeg/lib/$file
  done

  rm -rf lib_n lib_h
  rm -rf $INSTALL_PREFIX/ffmpeg_h
)
fi
