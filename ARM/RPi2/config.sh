#!/bin/sh

export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib
export NPROC=$(nproc)

export AR="arm-linux-gnueabihf-gcc-ar-9"
export CC="arm-linux-gnueabihf-gcc-9"
export CXX="arm-linux-gnueabihf-g++-9"
export CPP="arm-linux-gnueabihf-cpp-9"
export RANLIB="arm-linux-gnueabihf-gcc-ranlib-9"
export LD="$CXX"

export CFLAGS="-O3 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -g0"
export CXXFLAGS="-O3 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -g0"
