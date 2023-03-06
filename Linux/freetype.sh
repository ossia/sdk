#!/bin/bash

source ./common.sh

if [[ ! -d freetype ]]; then
(
  $GIT clone https://github.com/jcelerier/freetype
  $GIT clone https://github.com/harfbuzz/harfbuzz
)
fi

# 1. Build freetype without harfbuzz
(
$CMAKE \
  -S freetype \
  -B freetype-build \
  -DFT_DISABLE_ZLIB=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

$CMAKE --build freetype-build --parallel
$CMAKE --build freetype-build --target install/strip
)

# 2. Build harfbuzz

(
  cd harfbuzz
  export LIBRARY_PATH=$INSTALL_PREFIX/freetype
  export PKG_CONFIG_PATH=$INSTALL_PREFIX/freetype/lib64/pkgconfig
  meson build -Dbuildtype=$MESON_BUILD_TYPE -Ddefault_library=static -Dglib=disabled -Dgobject=disabled -Dicu=disabled -Ddocs=disabled -Dprefix=$INSTALL_PREFIX/harfbuzz 
  cd build
  ninja
  ninja install
  ln -s $INSTALL_PREFIX/harfbuzz/lib64 $INSTALL_PREFIX/harfbuzz/lib
)

# 3. Build freetype with harfbuzz
(
$CMAKE \
  -S freetype \
  -B freetype-build-final \
  -DFT_DISABLE_ZLIB=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=FALSE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX/harfbuzz \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

$CMAKE --build freetype-build-final --parallel
$CMAKE --build freetype-build-final --target install/strip
)
