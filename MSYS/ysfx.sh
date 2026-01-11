#!/bin/bash

source ./common.sh
source ../common/clone-ysfx.sh

export FREETYPE_DIR=$INSTALL_PREFIX/freetype

cmake \
  -S ysfx \
  -B ysfx-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DYSFX_PLUGIN=OFF \
  -DYSFX_DEEP_STRIP=OFF \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/ysfx 

cmake --build ysfx-build 
cmake --build ysfx-build --target install/strip

mv $INSTALL_PREFIX/ysfx/include/ysfx.h $INSTALL_PREFIX/ysfx/include/ysfx-s.h
mv $INSTALL_PREFIX/ysfx/lib/libysfx.a $INSTALL_PREFIX/ysfx/lib/libysfx-s.a
