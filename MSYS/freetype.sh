#!/bin/bash

source ./common.sh
source ../common/clone-freetype.sh

(
cmake \
  -GNinja \
  -S freetype \
  -B freetype-build \
  -DFT_DISABLE_ZLIB=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

cmake --build freetype-build --parallel
cmake --build freetype-build --target install/strip
)
  
# 2. Build harfbuzz
(
  cd harfbuzz
  export LIBRARY_PATH=$INSTALL_PREFIX/freetype
  export PKG_CONFIG_PATH=$INSTALL_PREFIX/freetype/lib/pkgconfig
  meson build -Dbuildtype=release -Ddefault_library=static -Dglib=disabled -Dgobject=disabled -Dicu=disabled -Ddocs=disabled -Dprefix=$INSTALL_PREFIX/harfbuzz 
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
  -DFT_DISABLE_ZLIB=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX/harfbuzz \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

cmake --build freetype-build-final --parallel
cmake --build freetype-build-final --target install/strip
)