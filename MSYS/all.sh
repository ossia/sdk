#!/bin/bash

# ./deps.sh

# TODO install python in SDK needed for qt

# TODO install meson from MSI 
# e.g. https://github.com/mesonbuild/meson/releases/download/1.5.0/meson-1.5.0-64.msi

# TODO install mingw-w64-clang-x86_64-cppwinrt 
# and 
# cp -rf /clang64/include/winrt/ /d/ossia-sdk/sysroot/include/


./cmake.sh
./zlib.sh
./freetype.sh
./llvm-deps.sh
./llvm.sh
./qt.sh
./ffmpeg.sh
./fftw.sh
./portaudio.sh
./sdl.sh
./faust.sh
./jack.sh
./dnssd.sh
./ysfx.sh
