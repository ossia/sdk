#!/bin/bash -eu

source ./common.sh clang
source ./common/clone-portaudio.sh

cmake -S portaudio -B portaudio-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
 -DPA_ALSA_DYNAMIC=ON \
 -DPA_USE_JACK=OFF \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/portaudio

cmake --build portaudio-build
cmake --build portaudio-build --target install/strip
