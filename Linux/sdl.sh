#!/bin/bash

source ./common.sh

wget -nv https://www.libsdl.org/release/SDL2-2.0.9.tar.gz
gtar xaf SDL2-2.0.9.tar.gz

mkdir sdl-build
cd sdl-build

$CMAKE -DSDL_STATIC=1 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/SDL2 \
 ../SDL2-2.0.9

make -j$NPROC
make install
