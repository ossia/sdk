#!/bin/bash

source ./common.sh

if [[ ! -d fontconfig ]]; then
(
  $GIT clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git
)
fi

$CMAKE \
  -S fontconfig \
  -B fontconfig-build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/fontconfig

$CMAKE --build fontconfig-build --parallel
$CMAKE --build fontconfig-build --target install/strip
