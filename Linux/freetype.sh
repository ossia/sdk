#!/bin/bash -e

source ./common.sh clang
source ./common/clone-freetype.sh

# FIXME
# Freetype links against libz.so and libbz2.so instead of .a
# Freetype adds libbrotlidec.a but not libbrotlicommon.a 
# 1. Build freetype without harfbuzz
(
cmake \
  -S "$FREETYPE_SRC" \
  -B "$FREETYPE_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX/sysroot" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX/sysroot"

cmake --build "$FREETYPE_SRC-build" --parallel
cmake --build "$FREETYPE_SRC-build" --target install/strip
)

# 2. Build harfbuzz

(
  cd "$HARFBUZZ_SRC"
  export LIBRARY_PATH=$INSTALL_PREFIX/sysroot
  export PKG_CONFIG_PATH=$INSTALL_PREFIX/sysroot/lib64/pkgconfig
  meson build \
    "${MESON_COMMON_FLAGS[@]}" \
    -Dglib=disabled \
    -Dgobject=disabled \
    -Dicu=disabled \
    -Ddocs=disabled \
    -Dtests=disabled \
    "${HB_SHAPING_ONLY[@]}" \
    -Dprefix=$INSTALL_PREFIX/sysroot
  cd build
  ninja
  ninja install
  if [[ -d "$INSTALL_PREFIX/sysroot/lib64" && ! -e "$INSTALL_PREFIX/sysroot/lib" ]]; then
    ln -s lib64 "$INSTALL_PREFIX/sysroot/lib"
  fi
)

# 3. Build freetype with harfbuzz
(
cmake \
  -S "$FREETYPE_SRC" \
  -B "$FREETYPE_SRC-build-final" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX/sysroot" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX/sysroot"

cmake --build "$FREETYPE_SRC-build-final" --parallel
cmake --build "$FREETYPE_SRC-build-final" --target install/strip
)
