#!/bin/bash

source ./common.sh

git clone https://github.com/portaudio/portaudio

mkdir -p portaudio_build
cd portaudio_build

xcrun cmake ../portaudio \
 -GNinja \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=OFF \
 -DPA_USE_JACK=OFF \
 -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/portaudio \
  $CMAKE_ADDITIONAL_FLAGS

xcrun cmake --build . --parallel
xcrun cmake --build . --parallel --target install/strip
