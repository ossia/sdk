#!/bin/bash

source ./common.sh

if [[ ! -d portaudio ]]; then
  $GIT clone https://github.com/portaudio/portaudio
fi

mkdir -p portaudio/build
cd portaudio/build

$CMAKE .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
 -DPA_BUILD_SHARED=OFF \
 -DPA_ALSA_DYNAMIC=ON \
 -DPA_USE_JACK=OFF \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/portaudio

make -j$NPROC
make install/strip
