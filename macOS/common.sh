#!/bin/bash
export MACOS_VERSION=10.11
export NPROC=$(sysctl -n hw.logicalcpu)
export INSTALL_PREFIX=/opt/score-sdk
export SDK_ROOT=$PWD

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export CFLAGS="-O3 -mmacosx-min-version=$MACOS_VERSION"
  export CXXFLAGS="-O3 -mmacosx-min-version=$MACOS_VERSION"
fi