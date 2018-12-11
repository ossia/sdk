#!/bin/bash
export NPROC=4
export INSTALL_PREFIX=/c/score-sdk
export INSTALL_PREFIX_CMAKE=c:/score-sdk
export SDK_ROOT=$PWD

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm-libs/bin:$INSTALL_PREFIX/llvm/bin:$PATH
  export CFLAGS="-O3"
  export CXXFLAGS="-O3"
fi
