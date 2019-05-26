#!/bin/bash

source ./common.sh

wget -nv https://www.libsdl.org/release/SDL2-2.0.9.tar.gz
tar.exe xaf SDL2-2.0.9.tar.gz

mkdir sdl-build
cd sdl-build

cmake \
 -DSDL_STATIC=1 \
 -G"MSYS Makefiles" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/SDL2 \
 ../SDL2-2.0.9

make -j$NPROC
make install
