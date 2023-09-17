#!/bin/bash

TOOLCHAIN="$1"
if [[ -z "$TOOLCHAIN" ]]; then
  echo "Pass a toolchain argument: gcc or clang"
  exit 1
fi

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)

export NPROC=$(nproc)
export SDK_INSTALL_ROOT=/opt/ossia-sdk-rpi-aarch64
export SYSROOT=/opt/ossia-sdk-rpi-aarch64/pi/sysroot
export INSTALL_PREFIX=$SDK_INSTALL_ROOT/pi/sysroot/opt/ossia-sdk-rpi
export INSTALL_PREFIX_CMAKE=$SDK_INSTALL_ROOT/pi/sysroot/opt/ossia-sdk-rpi
export CROSS_COMPILER_ARCHIVE=x-tools-aarch64-rpi3-linux-gnu.tar.xz
export SDK_ROOT=$PWD
export GIT=git
export CMAKE=cmake
export CFLAGS="-O3 -g0 -mcpu=cortex-a72"
export CXXFLAGS="-O3 -g0 -mcpu=cortex-a72"
export LLVM_DEFAULT_TARGET_TRIPLE=aarch64-linux-gnu
export LLVM_TARGET_ARCH=aarch64
export LLVM_TARGET=AArch64
export FFMPEG_ARCH=aarch64
export FFTW_CROSS=aarch64-none-linux-gnu
export QT_CROSS_DEVICE=linux-rasp-pi4-aarch64-g++
export DEBIAN_MULTIARCH_FOLDER=aarch64-rpi3-linux-gnu
export CROSS_TOOLS_PREFIX=aarch64-rpi3-linux-gnu-

# GCC
if [[ "$TOOLCHAIN" == "gcc" ]]; then
  export CMAKE_TOOLCHAIN=$SDK_INSTALL_ROOT/toolchain.aarch64.cmake
  export CROSS_COMPILER_LOCATION=$SDK_INSTALL_ROOT/aarch64-rpi3-linux-gnu
  export CCPREFIX=$CROSS_COMPILER_LOCATION/bin/$CROSS_TOOLS_PREFIX
  export CC=$CROSS_COMPILER_LOCATION/bin/aarch64-rpi3-linux-gnu-gcc
  export CXX=$CROSS_COMPILER_LOCATION/bin/aarch64-rpi3-linux-gnu-g++
elif [[ "$TOOLCHAIN" == "clang" ]]; then
  export CMAKE_TOOLCHAIN=$SDK_INSTALL_ROOT/toolchain.aarch64.llvm-host.cmake
  export CROSS_COMPILER_LOCATION=$SDK_INSTALL_ROOT/pi/llvm-16
  export CC=$CROSS_COMPILER_LOCATION/bin/clang
  export CXX=$CROSS_COMPILER_LOCATION/bin/clang++
fi

export CMAKE_BUILD_TYPE=Release
export MESON_BUILD_TYPE=release
export QT_MODE="release"
export LLVM_ADDITIONAL_FLAGS=" "

# For meson:
export LIBRARY_PATH=$INSTALL_PREFIX/sysroot
export MESON_COMMON_FLAGS=(
    -Dbuildtype=$MESON_BUILD_TYPE
    -Ddefault_library=static
)
export CMAKE_COMMON_FLAGS=(
  -GNinja
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE
  -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"