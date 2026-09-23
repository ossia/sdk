#!/bin/bash

source ./common.sh clang
source ./common/clone-ysfx.sh

export FREETYPE_DIR=$INSTALL_PREFIX/freetype

$CMAKE \
  -S ysfx \
  -B ysfx-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DYSFX_PLUGIN=OFF \
  -DYSFX_DEEP_STRIP=OFF \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/ysfx 

$CMAKE --build ysfx-build --parallel
$CMAKE --build ysfx-build --target "${CMAKE_INSTALL_TARGET:-install/strip}"

mv $INSTALL_PREFIX/ysfx/include/ysfx.h $INSTALL_PREFIX/ysfx/include/ysfx-s.h
mv $INSTALL_PREFIX/ysfx/lib64/libysfx.a $INSTALL_PREFIX/ysfx/lib64/libysfx-s.a
