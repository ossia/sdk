#!/bin/bash

source ./common.sh

if [[ ! -f SDL2-2.0.10.tar.gz ]]; then
  wget -nv https://www.libsdl.org/release/SDL2-2.0.10.tar.gz
  tar xaf SDL2-2.0.10.tar.gz
fi

mkdir sdl-build
cd sdl-build

$CMAKE -DSDL_STATIC=1 \
 -DSDL_STATIC_PIC=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/SDL2 \
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
 -DSDL_SENSOR=0 \
 ../SDL2-2.0.10

make -j$NPROC
make install
