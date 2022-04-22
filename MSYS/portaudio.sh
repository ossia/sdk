#!/bin/bash

source ./common.sh

if [[ ! -d portaudio ]]; then
(
  git clone https://github.com/jcelerier/portaudio
  cd portaudio
  git checkout patch-2
)
fi

rm -rf portaudio/build
mkdir -p portaudio/build
cd portaudio/build

cmake .. \
 -GNinja \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=Off \
 -DPA_USE_ASIO=ON \
 -DPA_DLL_LINK_WITH_STATIC_RUNTIME=Off \
 -DASIOSDK_PATH_HINT=$PWD/ASIOSDK2.3.2 \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/portaudio

cmake --build .
cmake --build . --target install/strip
