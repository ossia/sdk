#!/bin/bash

source ./common.sh
source ../common/clone-sdl3.sh

rm -rf sdl3-build
mkdir sdl3-build

export CFLAGS="${CFLAGS:-} -DSDL_DYNAMIC_API=0"
export CXXFLAGS="${CXXFLAGS:-} -DSDL_DYNAMIC_API=0"

cmake  -S SDL3-$SDL3_VERSION -B sdl3-build \
-GNinja \
 -DSDL_STATIC=1 \
 -DSDL_SHARED=0 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/SDL3 \
 -DSDL_JOYSTICK=1 \
 -DSDL_HAPTIC=1 \
 -DSDL_HIDAPI=1 \
 -DSDL_HIDAPI_JOYSTICK=1 \
 -DSDL_POWER=1 \
 -DSDL_SENSOR=1 \
 -DSDL_AUDIO=0 \
 -DSDL_VIDEO=1 \
 -DSDL_RENDER=0 \
 -DSDL_CAMERA=0 \
 -DSDL_GPU=0 \
 -DSDL_DIALOG=0 \
 -DSDL_TRAY=0 \
 -DSDL_OPENGL=0 \
 -DSDL_OPENGLES=0 \
 -DSDL_VULKAN=0 \
 -DSDL_TEST_LIBRARY=0 \
 -DSDL_TESTS=0 \
 -DSDL_EXAMPLES=0 \
 -DSDL_INSTALL_CPACK=0

cmake --build sdl3-build
cmake --build sdl3-build --target install/strip
