#!/bin/bash

wget https://github.com/Kitware/CMake/releases/download/v3.26.0-rc5/cmake-3.26.0-rc5-linux-x86_64.tar.gz
tar xaf cmake-3.26.0-rc5-linux-x86_64.tar.gz
rm cmake-3.26.0-rc5-linux-x86_64.tar.gz
mv cmake-3.26.0-rc5-linux-x86_64 cmake 

./llvm-deps.sh
./llvm.sh
./faust.sh
./ffmpeg.sh
./fftw.sh
./openssl.sh
./freetype.sh
./qt.sh
./sdl.sh
./portaudio.sh
./jack.sh
./ysfx.sh
# ./qgnomeplatform.sh


