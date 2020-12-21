#!/bin/bash

# ./deps.sh
# ./llvm.sh
./qt.sh
./fftw.sh
./ffmpeg.sh
./portaudio.sh
./sdl.sh
./jack.sh
./llvm-libs.sh
./faust.sh


tar caf score-sdk-mac.tar.gz /opt/ossia-sdk

