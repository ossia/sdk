#!/bin/bash -eu

source ./common.sh
source ../common/clone-faust.sh

cd faust/build
mkdir -p faustdir
export PATH=$PATH:$INSTALL_PREFIX/llvm-libs/bin
xcrun cmake \
  -S . \
  -B faustdir \
  -GNinja \
  -C ./backends/llvm.cmake \
  -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX/llvm-libs \
  -DCMAKE_BUILD_TYPE=Release \
  -DINCLUDE_OSC=0 \
  -DINCLUDE_HTTP=0 \
  -DINCLUDE_EXECUTABLE=0 \
  -DINCLUDE_STATIC=1 \
  -DLINK_LLVM_STATIC=0 \
  -DINCLUDE_LLVM=0 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
  -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/faust \
  -DCMAKE_C_VISIBLITY_PRESET=hidden \
  -DCMAKE_CXX_VISIBLITY_PRESET=hidden \
  -DCMAKE_VISIBLITY_INLINES_HIDDEN=1 \
  $CMAKE_ADDITIONAL_FLAGS
  
xcrun cmake --build faustdir
xcrun cmake --build faustdir --target install/strip
