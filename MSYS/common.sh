#!/bin/bash
export NPROC=12
export INSTALL_PREFIX=/c/ossia-sdk
export INSTALL_PREFIX_CMAKE=c:/ossia-sdk
export SDK_ROOT=$PWD

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export CFLAGS="-O3"
  export CXXFLAGS="-O3"
fi
