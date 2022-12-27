#!/bin/bash

source ./common.sh

if [[ ! -d portaudio ]]; then
  git clone https://github.com/portaudio/portaudio
fi

mkdir -p portaudio/build
cd portaudio/build

cmake .. \
 -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
 -DBUILD_SHARED_LIBS=OFF \
 -DPA_ALSA_DYNAMIC=ON \
 -DPA_USE_JACK=OFF \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/portaudio

make -j$NPROC
make install/strip
