#!/bin/bash
export NPROC=12
export INSTALL_PREFIX=/c/ossia-sdk
export INSTALL_PREFIX_CMAKE=c:/ossia-sdk
export INSTALL_PREFIX_WIN32=c:\\ossia-sdk
export SDK_ROOT=$PWD
export TOOLS_ROOT=/d/gnu/bin

export CC=clang
export CXX=clang++
export CFLAGS="-O3"
export CXXFLAGS="-O3"

export PATH="$INSTALL_PREFIX/cmake/bin:$INSTALL_PREFIX/python:$INSTALL_PREFIX/python/Scripts:$TOOLS_ROOT:$PATH"
if ! command -v mingw32-make &> /dev/null; then
  export MAKE=make
else
  export MAKE=mingw32-make
fi

source ../common/versions.sh
if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export CFLAGS="-O3"
  export CXXFLAGS="-O3"
fi
