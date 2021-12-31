#!/bin/bash

source ./common.sh

if [[ ! -d ysfx ]]; then
(
  $GIT clone --recursive https://github.com/jcelerier/ysfx
)
fi

export FREETYPE_DIR=$INSTALL_PREFIX/freetype

$CMAKE \
  -S ysfx \
  -B ysfx-build \
  -DYSFX_PLUGIN=OFF \
  -DYSFX_DEEP_STRIP=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/ysfx 

$CMAKE --build ysfx-build --parallel
$CMAKE --build ysfx-build --target install/strip
