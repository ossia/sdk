#!/bin/bash

# ./deps.sh
# ./llvm-deps.sh

./freetype.sh
./qt.sh
# ./fftw.sh
./ffmpeg.sh
# ./sndfile.sh
# ./portaudio.sh
./sdl.sh
./jack.sh
./llvm-libs.sh
./faust.sh
./ysfx.sh



tar caf sdk-macOS.tar.gz $INSTALL_PREFIX

