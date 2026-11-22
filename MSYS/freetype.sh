#!/bin/bash -e

source ./common.sh
source ../common/clone-freetype.sh

(
cmake \
  -S "$FREETYPE_SRC" \
  -B "$FREETYPE_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DFT_DISABLE_BZIP2=TRUE \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"

cmake --build "$FREETYPE_SRC-build" --parallel
cmake --build "$FREETYPE_SRC-build" --target install/strip
)

# 2. Build harfbuzz
(
  cd "$HARFBUZZ_SRC"
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

# 3. Rebuild freetype with harfbuzz
(
cmake \
  -S "$FREETYPE_SRC" \
  -B "$FREETYPE_SRC-build-final" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DFT_DISABLE_BZIP2=TRUE \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/sysroot

cmake --build "$FREETYPE_SRC-build-final"
cmake --build "$FREETYPE_SRC-build-final" --target install/strip
)
