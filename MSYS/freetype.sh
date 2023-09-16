#!/bin/bash

source ./common.sh
source ../common/clone-freetype.sh

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"

(
cmake \
  -GNinja \
  -S freetype \
  -B freetype-build \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX/sysroot" \
  -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DBZIP2_INCLUDE_DIR="$INSTALL_PREFIX_CMAKE/sysroot/include" \
  -DBZIP2_LIBRARIES="$INSTALL_PREFIX_CMAKE/sysroot/lib/libbz2.a" \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/sysroot

cmake --build freetype-build --parallel
cmake --build freetype-build --target install/strip
)

# 2. Build harfbuzz
(
  cd harfbuzz
  export LIBRARY_PATH=$INSTALL_PREFIX/sysroot
  meson build -Dbuildtype=release -Ddefault_library=static -Dglib=disabled -Dgobject=disabled -Dicu=disabled -Ddocs=disabled -Dtests=disabled -Dprefix=$INSTALL_PREFIX/sysroot 
  cd build
  ninja
  ninja install
)

# 3. Rebuild freetype with harfbuzz
(
cmake \
  -GNinja \
  -S freetype \
  -B freetype-build-final \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX/sysroot" \
  -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DBZIP2_INCLUDE_DIR="$INSTALL_PREFIX_CMAKE/sysroot/include" \
  -DBZIP2_LIBRARIES="$INSTALL_PREFIX_CMAKE/sysroot/lib/libbz2.a" \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/sysroot

cmake --build freetype-build-final --parallel
cmake --build freetype-build-final --target install/strip
)