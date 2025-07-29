#!/bin/bash -eux

source ./common.sh
source ../common/clone-faust.sh

export PATH=$INSTALL_PREFIX/llvm-libs/bin:$PATH
echo $PATH
# which llvm-config

cmake -G Ninja \
  -C faust/build/backends/llvm.cmake \
  -S faust/build \
  -B faust-build \
  -DCMAKE_C_FLAGS="$CFLAGS -DFAUSTFLOAT=double" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS -DFAUSTFLOAT=double" \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_BUILD_TYPE=Release \
  -DINCLUDE_OSC=0 \
  -DINCLUDE_HTTP=0 \
  -DINCLUDE_EMCC=0 \
  -DINCLUDE_EXECUTABLE=0 \
  -DINCLUDE_STATIC=1 \
  -DUSE_LLVM_CONFIG=0 \
  -DINCLUDE_LLVM_STATIC_IN_ARCHIVE=0 \
  -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX_CMAKE/llvm-libs \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/faust

#  -DLLVM_CONFIG=$INSTALL_PREFIX_CMAKE/llvm-libs/bin/llvm-config.exe \

cmake --build faust-build
cmake --build faust-build --target install/strip
