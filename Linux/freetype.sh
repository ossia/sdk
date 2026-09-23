#!/bin/bash -e

source ./common.sh clang
source ./common/clone-freetype.sh
if [[ -f "$INSTALL_PREFIX/sysroot/.ossia-sdk-freetype-complete" ]]; then
  exit 0
fi

# FIXME
# Freetype links against libz.so and libbz2.so instead of .a
# Freetype adds libbrotlidec.a but not libbrotlicommon.a 
# 1. Build freetype without harfbuzz
(
cmake \
  -S freetype \
  -B freetype-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DDISABLE_FORCE_DEBUG_POSTFIX=ON \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX/sysroot" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX/sysroot"

cmake --build freetype-build --parallel
cmake --build freetype-build --target "${CMAKE_INSTALL_TARGET:-install/strip}"
)

# 2. Build harfbuzz

(
  # HarfBuzz promotes -Wunused to an error in hb.hh. Clang 23 expanded that
  # group to include -Wunused-template, exposing intentionally dormant generic
  # overloads. Use HarfBuzz's supported escape hatch for its internal pragmas.
  export CXXFLAGS="$CXXFLAGS -DHB_NO_PRAGMA_GCC_DIAGNOSTIC_ERROR"
  cd harfbuzz
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
)

# 3. Build freetype with harfbuzz
(
cmake \
  -S freetype \
  -B freetype-build-final \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DDISABLE_FORCE_DEBUG_POSTFIX=ON \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX/sysroot" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX/sysroot"

cmake --build freetype-build-final --parallel
cmake --build freetype-build-final --target "${CMAKE_INSTALL_TARGET:-install/strip}"
touch "$INSTALL_PREFIX/sysroot/.ossia-sdk-freetype-complete"
)
