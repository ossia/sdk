#!/bin/bash

export CMAKE_VER=3.30.2
wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VER/cmake-$CMAKE_VER-linux-x86_64.tar.gz
tar xaf cmake-$CMAKE_VER-linux-x86_64.tar.gz
rm cmake-$CMAKE_VER-linux-x86_64.tar.gz
mv cmake-$CMAKE_VER-linux-x86_64 cmake

wget https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
unzip ninja-linux.zip
mv -f ninja /usr/bin

./llvm.sh
./faust.sh
./ffmpeg.sh
./fftw.sh
./openssl.sh
./freetype.sh
./fontconfig.sh
./qt.sh
./sdl.sh
./portaudio.sh
./jack.sh
./pipewire.sh
./lv2.sh
./ysfx.sh
# ./qgnomeplatform.sh


