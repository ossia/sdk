#!/bin/bash

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
export NPROC=12
export INSTALL_PREFIX=/c/ossia-sdk-x86_64
export INSTALL_PREFIX_CMAKE=c:/ossia-sdk-x86_64
export INSTALL_PREFIX_WIN32=c:\\ossia-sdk-x86_64
export SDK_ROOT=$PWD
export TOOLS_ROOT=/c/gnu/bin

export CC=clang
export CXX=clang++
export CFLAGS="-O3 -march=x86-64-v3"
export CXXFLAGS="-O3 -march=x86-64-v3"
export LDFLAGS=""

export PATH="$INSTALL_PREFIX/cmake/bin:$INSTALL_PREFIX/python:$INSTALL_PREFIX/python/Scripts:$TOOLS_ROOT:$PATH:/c/Program Files/Meson"
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
  export CFLAGS="-O3 -fno-stack-protector -fnew-infallible "
  export CXXFLAGS="-O3 -fno-stack-protector -fnew-infallible "
fi

export CMAKE_BUILD_TYPE=Release
export MESON_BUILD_TYPE=release
export QT_MODE="release"
export LLVM_ADDITIONAL_FLAGS=" "

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
