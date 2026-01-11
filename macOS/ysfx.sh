#!/bin/bash -eu

source ./common.sh
source ../common/clone-ysfx.sh

export FREETYPE_DIR=$INSTALL_PREFIX/freetype

cmake \
  -S ysfx \
  -B ysfx-build \
  -GNinja \
  -DYSFX_PLUGIN=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  $CMAKE_ADDITIONAL_FLAGS \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/ysfx 

cmake --build ysfx-build --parallel
cmake --build ysfx-build --target install/strip

mv $INSTALL_PREFIX/ysfx/include/ysfx.h $INSTALL_PREFIX/ysfx/include/ysfx-s.h
mv $INSTALL_PREFIX/ysfx/lib/libysfx.a $INSTALL_PREFIX/ysfx/lib/libysfx-s.a
