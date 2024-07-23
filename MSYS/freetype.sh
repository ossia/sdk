#!/bin/bash

source ./common.sh
source ../common/clone-freetype.sh

(
cmake \
  -S freetype \
  -B freetype-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DBZIP2_INCLUDE_DIR="$INSTALL_PREFIX_CMAKE/sysroot/include" \
  -DBZIP2_LIBRARIES="$INSTALL_PREFIX_CMAKE/sysroot/lib/libbz2.a" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"

cmake --build freetype-build --parallel
cmake --build freetype-build --target install/strip
)

# 2. Build harfbuzz
(
  cd harfbuzz
  meson build \
    "${MESON_COMMON_FLAGS[@]}" \
    -Dglib=disabled \
    -Dgobject=disabled \
    -Dicu=disabled \
    -Ddocs=disabled \
    -Dtests=disabled \
    -Dprefix=$INSTALL_PREFIX/sysroot 
  cd build
  ninja
  ninja install

  sed -i 's/ SHARED / STATIC /g' "$INSTALL_PREFIX/sysroot//lib/cmake/harfbuzz/harfbuzz-config.cmake"
"
)

# 3. Rebuild freetype with harfbuzz
(
cmake \
  -S freetype \
  -B freetype-build-final \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DBZIP2_INCLUDE_DIR="$INSTALL_PREFIX_CMAKE/sysroot/include" \
  -DBZIP2_LIBRARIES="$INSTALL_PREFIX_CMAKE/sysroot/lib/libbz2.a" \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/sysroot

cmake --build freetype-build-final
cmake --build freetype-build-final --target install/strip
)
