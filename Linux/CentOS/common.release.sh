#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk
export SDK_ROOT=$PWD
export CFLAGS="-DNDEBUG -O3 -march=x86-64 -mtune=generic -fno-plt -fno-semantic-interposition -fno-stack-protector -pthread -fPIC " # -march=ivybridge -mtune=haswell"
export CXXFLAGS="$CFLAGS" # -march=ivybridge -mtune=haswell"

export LD_LIBRARY_PATH=
if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CXXFLAGS="$CXXFLAGS -fnew-infallible"
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib
fi

export PATH=$SDK_ROOT/cmake/bin:$PATH
export GIT=/usr/bin/git
export CMAKE=$SDK_ROOT/cmake/bin/cmake
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-git218/root/usr/lib:/opt/rh/httpd24/root/usr/lib64


export CMAKE_BUILD_TYPE=Release
export MESON_BUILD_TYPE=release
export QT_MODE="release"
export LLVM_ADDITIONAL_FLAGS=" "
