#!/bin/bash
export NPROC=$(nproc)
export SDK_INSTALL_ROOT=/opt/ossia-sdk-rpi
export INSTALL_PREFIX=/opt/ossia-sdk-rpi/pi/sysroot/opt/ossia-sdk-rpi
export CROSS_COMPILER_LOCATION=$SDK_INSTALL_ROOT/armv8-rpi3-linux-gnueabihf
export SDK_ROOT=$PWD
export GIT=git
export CMAKE=cmake
export CFLAGS="-O3 -g0 -mcpu=cortex-a72"
export CXXFLAGS="-O3 -g0 -mcpu=cortex-a72"
export LLVM_DEFAULT_TARGET_TRIPLE=armv8-linux-gnueabihf
export LLVM_TARGET_ARCH=armv8
export DEBIAN_MULTIARCH_FOLDER=armv8-rpi3-linux-gnueabihf
export CROSS_TOOLS_PREFIX=armv8-rpi3-linux-gnueabihf-

export CCPREFIX=$CROSS_COMPILER_LOCATION/bin/$CROSS_TOOLS_PREFIX

export CC=$CROSS_COMPILER_LOCATION/bin/armv8-rpi3-linux-gnueabihf-gcc
export CXX=$CROSS_COMPILER_LOCATION/bin/armv8-rpi3-linux-gnueabihf-g++