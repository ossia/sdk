#!/bin/bash
export NPROC=$(nproc)
export SDK_INSTALL_ROOT=/opt/ossia-sdk-rpi
export INSTALL_PREFIX=/opt/ossia-sdk-rpi/pi/sysroot/opt/ossia-sdk-rpi
export CROSS_COMPILER_LOCATION=$SDK_INSTALL_ROOT/cross-pi-gcc-10.3.0-2
export SDK_ROOT=$PWD
export GIT=git
export CMAKE=cmake
export CFLAGS="-O3 -g0 -mcpu=cortex-a72"
export CXXFLAGS="-O3 -g0 -mcpu=cortex-a72"


export CC=$CROSS_COMPILER_LOCATION/bin/arm-linux-gnueabihf-gcc
export CXX=$CROSS_COMPILER_LOCATION/bin/arm-linux-gnueabihf-g++