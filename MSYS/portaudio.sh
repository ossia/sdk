#!/bin/bash

source ./common.sh
if [[ ! -f ASIOSDK2.3.2.zip ]]; then
  wget -nv http://www.steinberg.net/sdk_downloads/ASIOSDK2.3.2.zip
  unzip ASIOSDK2.3.2.zip
fi

if [[ ! -d portaudio ]]; then
  git clone https://github.com/portaudio/portaudio
  cd portaudio
  git merge origin/winrt -m 'merge wasapi patch'
fi

sed -i '378i TARGET_INCLUDE_DIRECTORIES(portaudio_static PUBLIC "$<INSTALL_INTERFACE:include>")' portaudio/CMakeLists.txt

rm -rf portaudio/build
mkdir -p portaudio/build
cd portaudio/build

cmake .. \
 -G"MSYS Makefiles" \
 -DCMAKE_BUILD_TYPE=Release \
 -DPA_BUILD_SHARED=Off \
 -DPA_DLL_LINK_WITH_STATIC_RUNTIME=Off \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/portaudio

make -j$NPROC
make install
