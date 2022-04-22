#!/bin/bash

source ./common.sh

if [[ ! -d ysfx ]]; then
(
  git clone --recursive https://github.com/jcelerier/ysfx
)
fi

export FREETYPE_DIR=$INSTALL_PREFIX/freetype

cmake \
  -GNinja \
  -S ysfx \
  -B ysfx-build \
  -DYSFX_PLUGIN=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/ysfx 

cmake --build ysfx-build --parallel
cmake --build ysfx-build --target install/strip
