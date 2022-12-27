#!/bin/bash
export NPROC=$(nproc)
export SDK_INSTALL_ROOT=/opt/ossia-sdk-rpi-aarch64
export INSTALL_PREFIX=$SDK_INSTALL_ROOT/pi/sysroot/opt/ossia-sdk-rpi
export CROSS_COMPILER_ARCHIVE=x-tools-aarch64-rpi3-linux-gnu.tar.xz
export CROSS_COMPILER_LOCATION=$SDK_INSTALL_ROOT/aarch64-rpi3-linux-gnu
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
export CMAKE_TOOLCHAIN=$PWD/toolchain.aarch64.cmake

export CCPREFIX=$CROSS_COMPILER_LOCATION/bin/$CROSS_TOOLS_PREFIX

export CC=$CROSS_COMPILER_LOCATION/bin/aarch64-rpi3-linux-gnu-gcc
export CXX=$CROSS_COMPILER_LOCATION/bin/aarch64-rpi3-linux-gnu-g++