#!/bin/bash

source scl_source enable gcc-toolset-11

cd /image
cp ./CentOS/common-centos.sh ./common.sh
./llvm-deps.sh
./qt-deps.sh
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


