#!/bin/bash

source ./common.sh

if [[ ! -d freetype ]]; then
(
  git clone https://github.com/jcelerier/freetype
)
fi

cmake \
  -S freetype \
  -B freetype-build \
  -DFT_DISABLE_ZLIB=TRUE \
  -DFT_DISABLE_BZIP2=TRUE \
  -DFT_DISABLE_PNG=TRUE \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_DISABLE_BROTLI=TRUE \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/freetype

cmake --build freetype-build --parallel
cmake --build freetype-build --target install/strip
