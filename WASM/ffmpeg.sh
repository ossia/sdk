#!/bin/bash

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh
source ../common/ffmpeg-features.sh
VERSION=$FFMPEG_VERSION

# ffmpeg's configure calls the raw llvm tools (llvm-nm, llvm-ranlib) directly;
# they live in emsdk's upstream/bin, which emsdk_env.sh does NOT put on PATH
# (it only adds .../upstream/emscripten). Scope this to the ffmpeg build.
if [[ -n "${EMSDK:-}" && -d "$EMSDK/upstream/bin" ]]; then
  export PATH="$EMSDK/upstream/bin:$PATH"
fi

# Same mirror chain as common/clone-ffmpeg.sh, for the same reason: ffmpeg.org
# is not reliable enough to gate CI on. It went down mid-run and, because this
# script had no error handling, the failed wget fell through to `tar` and then
# to configure, which died deep inside emconfigure with a bare
# "FileNotFoundError" -- three steps away from the actual problem.
#
# This file cannot just source clone-ffmpeg.sh: that applies the Raspberry Pi
# patch on Linux, which is where the WASM build runs, and WASM must not have it.
if [[ ! -d "ffmpeg-$VERSION" ]]; then
  fetch_ffmpeg() {
    curl -fksSLOJ "https://github.com/ossia/sdk/releases/download/sdk36/ffmpeg-$VERSION.tar.bz2" \
      && tar xjf "ffmpeg-$VERSION.tar.bz2" && return 0
    echo "WASM/ffmpeg.sh: not on the ossia mirror, falling back upstream" >&2
    curl -fksSL -o "ffmpeg-$VERSION.tar.gz" \
      "https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n$VERSION.tar.gz" \
      && mkdir -p "ffmpeg-$VERSION" \
      && tar xzf "ffmpeg-$VERSION.tar.gz" -C "ffmpeg-$VERSION" --strip-components=1 \
      && return 0
    curl -fksSLOJ "https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2" \
      && tar xjf "ffmpeg-$VERSION.tar.bz2"
  }
  if ! fetch_ffmpeg || [[ ! -d "ffmpeg-$VERSION" ]]; then
    echo "WASM/ffmpeg.sh: every source failed for ffmpeg-$VERSION" >&2
    exit 1
  fi
fi

mkdir  -p ffmpeg-build
cd ffmpeg-build


# Feature flags live in common/ffmpeg-features.wasm, which is SELF-CONTAINED --
# the shared desktop file is not layered under it (no network, no external
# codecs, no hardware; payload size is the binding constraint here).
ARGS=(
  $(ffmpeg_features wasm)
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

emconfigure ../ffmpeg-$VERSION/configure "${ARGS[@]}" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }
emmake make -j$NPROC
emmake make install
