#!/bin/bash

source ./common.sh
source ../common/clone-sdl.sh

rm -rf sdl-build
mkdir sdl-build
cd sdl-build

cmake  -S SDL2-$SDL_VERSION -B sdl-build \
-GNinja \
 -DSDL_STATIC_PIC=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_C_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DCMAKE_CXX_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/SDL2 \
 -DSDL_EVENTS=1 \
 -DSDL_JOYSTICK=1 \
 -DSDL_HAPTIC=1 \
 -DSDL_FILE=1 \
 -DSDL_AUDIO=0 \
 -DSDL_VIDEO=1 \
 -DSDL_RENDER=0 \
 -DSDL_POWER=1 \
 -DSDL_TIMERS=0 \
 -DSDL_LOADSO=1 \
 -DSDL_CPUINFO=0 \
 -DSDL_FILESYSTEM=0 \
 -DSDL_DLOPEN=0 \
 -DSDL_SYSTEM=1 

cmake --build sdl-build
cmake --build sdl-build --target install/strip
