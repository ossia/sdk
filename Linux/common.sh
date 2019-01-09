#!/bin/bash
export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/score-sdk
export SDK_ROOT=$PWD
export GIT=git
export CMAKE=cmake

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib
  export CFLAGS="-O3"
  export CXXFLAGS="-O3"
fi
