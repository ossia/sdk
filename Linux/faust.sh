#!/bin/bash -eu

source ./common.sh clang
source ../common/clone-faust.sh

if [[ -f $INSTALL_PREFIX/faust/bin/faustpath ]]; then
  exit 0
fi

(
  cd faust/build
  sed -i 's/no-rtti/rtti/g' CMakeLists.txt
  
  $CMAKE \
  -GNinja \
  -S . -B faustdir \
  -C ./backends/llvm.cmake \
  -DINCLUDE_OSC=0 \
  -DINCLUDE_HTTP=0 \
  -DINCLUDE_EXECUTABLE=0 \
  -DINCLUDE_STATIC=1 \
  -DLINK_LLVM_STATIC=0 \
  -DINCLUDE_LLVM=0 \
  -DINCLUDE_LLVM_STATIC_IN_ARCHIVE=0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/faust
  
  cmake --build faustdir
  cmake --build faustdir --target install/strip
)
