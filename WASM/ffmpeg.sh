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

if [[ ! -d ffmpeg-$VERSION ]]; then
  wget -nv https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
  tar xaf ffmpeg-$VERSION.tar.bz2
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
