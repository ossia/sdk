#!/bin/bash

source ./common.sh clang
source ../common/clone-portaudio.sh

cmake -S portaudio -B portaudio-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
 -DPA_USE_ASIO=ON \
 -DPA_USE_JACK=OFF \
 -DPA_DLL_LINK_WITH_STATIC_RUNTIME=Off \
 -DASIOSDK_PATH_HINT=$PWD/ASIOSDK2.3.2 \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/portaudio

cmake --build portaudio-build
cmake --build portaudio-build --target install/strip
