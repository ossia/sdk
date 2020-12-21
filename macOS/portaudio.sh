#!/bin/bash

source ./common.sh

git clone https://github.com/portaudio/portaudio

cd portaudio/build

xcrun cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DPA_BUILD_SHARED=OFF \
 -DPA_USE_JACK=OFF \
 -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/portaudio

xcrun make -j$NPROC
xcrun make install
