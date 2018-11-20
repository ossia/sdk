#!/bin/bash

wget -nv https://www.libsdl.org/release/SDL2-2.0.9.tar.gz
tar xaf SDL2-2.0.9.tar.gz

mkdir sdl-build
cd sdl-build

cmake -DSDL_STATIC=1 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=/opt/score-sdk/SDL2 ../SDL2-2.0.9

make -j4
make install