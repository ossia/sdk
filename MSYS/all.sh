#!/bin/bash

# ./deps.sh

# TODO install git bash in c:\git
# Otherwise fftw build fails due to c:\program files\git\usr\bin\sh.exe path with spaces

# TODO install python in SDK needed for qt

# TODO install meson from MSI 
# e.g. https://github.com/mesonbuild/meson/releases/download/1.5.0/meson-1.5.0-64.msi

# TODO install mingw-w64-clang-x86_64-cppwinrt 
# and 
# cp -rf /clang64/include/winrt/ /c/ossia-sdk/llvm/include/
# cp /clang64/lib/libruntimeobject.a /c/ossia-sdk/llvm/x86_64-w64-mingw32/lib/


# TODO install vulkan sdk from https://vulkan.lunarg.com/sdk/home#windows and reopen a shell


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
