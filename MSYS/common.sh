#!/bin/bash
export NPROC=12
export INSTALL_PREFIX=/d/ossia-sdk
export INSTALL_PREFIX_CMAKE=d:/ossia-sdk
export SDK_ROOT=$PWD

export CC=clang
export CXX=clang++
export CFLAGS="-O3"
export CXXFLAGS="-O3"
# if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
#   export CC=$INSTALL_PREFIX/llvm/bin/clang
#   export CXX=$INSTALL_PREFIX/llvm/bin/clang++
#   export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
#   export CFLAGS="-O3"
#   export CXXFLAGS="-O3"
# fi
