#!/bin/bash

source ./common.sh
if [[ ! -f ASIOSDK2.3.2.zip ]]; then
  wget -nv http://www.steinberg.net/sdk_downloads/ASIOSDK2.3.2.zip
  unzip ASIOSDK2.3.2.zip
fi

if [[ ! -d portaudio ]]; then
  git clone https://github.com/portaudio/portaudio
fi

rm -rf portaudio/build
mkdir -p portaudio/build
cd portaudio/build

cmake .. \
 -G"MSYS Makefiles" \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=Off \
 -DPA_DLL_LINK_WITH_STATIC_RUNTIME=Off \
 -DASIOSDK_PATH_HINT=$PWD/ASIOSDK2.3.2 \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/portaudio

make -j$NPROC
make install
