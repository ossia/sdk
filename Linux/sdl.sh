#!/bin/bash

source ./common.sh
source ./common/clone-sdl.sh

rm -rf sdl-build

$CMAKE  -S SDL2-$SDL_VERSION -B sdl-build \
 -GNinja \
 -DSDL_STATIC=1 \
 -DSDL_STATIC_PIC=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/SDL2 \
 -DCMAKE_C_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DCMAKE_CXX_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DSDL_EVENTS=1 \
 -DSDL_JOYSTICK=1 \
 -DSDL_HAPTIC=1 \
 -DSDL_FILE=1 \
 -DSDL_ATOMIC=0 \
 -DSDL_AUDIO=0 \
 -DSDL_VIDEO=0 \
 -DSDL_RENDER=0 \
 -DSDL_POWER=1 \
 -DSDL_SENSORS=1 \
 -DSDL_THREADS=1 \
 -DSDL_TIMERS=0 \
 -DSDL_LOADSO=0 \
 -DSDL_CPUINFO=0 \
 -DSDL_FILESYSTEM=0 \
 -DSDL_DLOPEN=0 \
 -DSDL_SYSTEM=1

cmake --build sdl-build
cmake --build sdl-build --target install/strip
