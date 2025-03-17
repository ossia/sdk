#!/bin/bash -eu
./ffmpeg.sh
exit 1
./cmake.sh
./llvm.sh
./zlib.sh
./faust.sh
./ffmpeg.sh
./fftw.sh
./openssl.sh
./freetype.sh
# ./fontconfig.sh
./sdl.sh
./portaudio.sh
./jack.sh
./pipewire.sh
./lv2.sh
./ysfx.sh
./qt.sh
# ./qgnomeplatform.sh


