#!/bin/bash

source ./common.sh

if [[ ! -d freetype ]]; then
(
  git clone https://github.com/jcelerier/freetype
  (cd freetype ; git checkout ossia-2023-04-09)
  git clone https://github.com/harfbuzz/harfbuzz
)
fi

# 1. Build freetype without harfbuzz
(
cmake \
  -S freetype \
  -B freetype-build \
  -DFT_DISABLE_ZLIB=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

cmake --build freetype-build --parallel
cmake --build freetype-build --target install/strip
)

# 2. Build harfbuzz

( 
  export MIN_SUPPORTED_MACOSX_DEPLOYMENT_TARGET=$MACOS_VERSION
  unset MACOSX_DEPLOYMENT_TARGET

  cd harfbuzz
  export LIBRARY_PATH=$INSTALL_PREFIX/freetype
  export PKG_CONFIG_PATH=$INSTALL_PREFIX/freetype/lib/pkgconfig
  meson build -Dbuildtype=release -Ddefault_library=static -Dglib=disabled -Dgobject=disabled -Dicu=disabled -Ddocs=disabled -Dprefix=$INSTALL_PREFIX/harfbuzz 
  cd build
  ninja
  ninja install
)

# 3. Build freetype with harfbuzz
(
cmake \
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
  -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

cmake --build freetype-build-final --parallel
cmake --build freetype-build-final --target install/strip
)
