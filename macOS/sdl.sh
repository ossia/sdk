#!/bin/bash

source ./common.sh

export SDL_VER=2.28.3
if [[ ! -f SDL2-$SDL_VER.tar.gz ]]; then
  wget -nv https://www.libsdl.org/release/SDL2-$SDL_VER.tar.gz
  gtar xaf SDL2-$SDL_VER.tar.gz
  gsed -i '/error Nope/d' SDL2-$SDL_VER/src/dynapi/SDL_dynapi.h
fi

mkdir sdl-build
cd sdl-build

xcrun cmake \
 -GNinja \
 -DSDL_STATIC=1 \
 -DSDL_STATIC_PIC=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/SDL2 \
 -DCMAKE_C_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DCMAKE_CXX_FLAGS="-DSDL_DYNAMIC_API=0" \
 -DSDL_EVENTS=1 \
 -DSDL_JOYSTICK=1 \
 -DSDL_HAPTIC=1 \
 -DSDL_FILE=1 \
 -DSDL_AUDIO=0 \
 -DSDL_VIDEO=0 \
 -DSDL_RENDER=0 \
 -DSDL_POWER=1 \
 -DSDL_LOADSO=0 \
 -DSDL_CPUINFO=0 \
 -DSDL_FILESYSTEM=0 \
 -DSDL_DLOPEN=0 \
  $CMAKE_ADDITIONAL_FLAGS \
 ../SDL2-$SDL_VER

xcrun cmake --build . --parallel
xcrun cmake --build . --parallel --target install/strip

ln -s $INSTALL_PREFIX/SDL2/SDL2.framework/Resources $INSTALL_PREFIX/SDL2/cmake
