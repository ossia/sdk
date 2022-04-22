#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk
export SDK_ROOT=$PWD
export CFLAGS="-O3 -march=x86-64 -mtune=generic -fno-plt -fno-semantic-interposition " # -march=ivybridge -mtune=haswell"
export CXXFLAGS="-O3 -march=x86-64 -mtune=generic -fno-plt -fno-semantic-interposition " # -march=ivybridge -mtune=haswell"

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib
else
  export LD_LIBRARY_PATH=
fi

export GIT=/usr/bin/git
export CMAKE=cmake3
