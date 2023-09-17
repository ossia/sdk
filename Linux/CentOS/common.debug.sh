#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk-debug
export SDK_ROOT=$PWD
export CFLAGS="-D_DEBUG -O3 -march=x86-64 -mtune=generic -D_FORTIFY_SOURCE=2 -fstack-protector-strong -fstack-clash-protection -pthread " # -march=ivybridge -mtune=haswell"
export CXXFLAGS="$CFLAGS" # -march=ivybridge -mtune=haswell"

export LD_LIBRARY_PATH=
if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CXXFLAGS="$CXXFLAGS -fnew-infallible"
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH

  if [[ -d "$INSTALL_PREFIX/llvm/lib/x86_64-unknown-linux-gnu" ]]; then
    export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib/x86_64-unknown-linux-gnu
  else
    export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib
  fi
fi

export PATH=$SDK_ROOT/cmake/bin:$PATH
export GIT=/usr/bin/git
export CMAKE=$SDK_ROOT/cmake/bin/cmake
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-git218/root/usr/lib:/opt/rh/httpd24/root/usr/lib64

export CMAKE_BUILD_TYPE=Debug
export MESON_BUILD_TYPE=debug
export QT_MODE="debug"
export LLVM_ADDITIONAL_FLAGS=" -DLIBCXX_ENABLE_ASSERTIONS=1 -DLIBCXX_ENABLE_DEBUG_MODE=1 "

export MESON_COMMON_FLAGS=(
    -Dbuildtype=$MESON_BUILD_TYPE
    -Ddefault_library=static
    -Dglib=disabled
    -Dgobject=disabled
    -Dicu=disabled
    -Ddocs=disabled
    -Dtests=disabled
)
export CMAKE_COMMON_FLAGS=(
  -GNinja
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"