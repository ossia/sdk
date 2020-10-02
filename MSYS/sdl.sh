#!/bin/bash

source ./common.sh
VERSION=2.0.12

wget -nv https://www.libsdl.org/release/SDL2-$VERSION.tar.gz
tar.exe xaf SDL2-$VERSION.tar.gz

mkdir sdl-build
cd sdl-build

cmake \
 -DSDL_STATIC_PIC=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_BUILD_TYPE=Release \
 -G"MSYS Makefiles" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_C_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DCMAKE_CXX_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/SDL2 \
 -DSDL_EVENTS=1 \
 -DSDL_JOYSTICK=1 \
 -DSDL_HAPTIC=1 \
 -DSDL_FILE=1 \
 -DSDL_ATOMIC=0 \
 -DSDL_AUDIO=0 \
 -DSDL_VIDEO=0 \
 -DSDL_RENDER=0 \
 -DSDL_POWER=0 \
 -DSDL_THREADS=0 \
 -DSDL_TIMERS=0 \
 -DSDL_LOADSO=0 \
 -DSDL_CPUINFO=0 \
 -DSDL_FILESYSTEM=0 \
 -DSDL_DLOPEN=0 \
 ../SDL2-$VERSION

make -j$NPROC
make install
