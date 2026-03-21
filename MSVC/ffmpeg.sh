#!/bin/bash

source ../common/clone-ffmpeg.sh

shopt -s nullglob

# https://github.com/nathan818fr/vcvars-bash
#msvc_version=$(ls "/c/Program Files/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/")
#msvc_path="/c/Program Files/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/$msvc_version/bin/Hostx64/x64"

#export PATH="$msvc_path:$PATH"
#:/d/msys64/clang64/bin"

# ffmpeg detects the compiler by parsing the output of cl.exe which changes with LANG
# https://zhuanlan.zhihu.com/p/1937091185752674763 
# export VSLANG=1033
# ^ actually does not work, need to make sure that ONLY the english language pack for visual studio is installed

# put nasm here:
# export PATH="/c/ossia-sdk-msvc/bin:$PATH"

# out of tree build does not work
cd ffmpeg-$FFMPEG_VERSION

./configure \
    --toolchain=msvc --target-os=win64 \
    --enable-asm  \
 	--disable-doc --disable-ffmpeg --disable-ffplay \
 	--disable-debug \
 	--pkg-config-flags="--static" \
 	--enable-gpl --enable-version3 \
 	--disable-openssl --disable-securetransport \
 	--disable-videotoolbox \
 	--disable-network --disable-iconv  --disable-response-files \
 	--enable-protocols  --disable-lzma \
 	--prefix=/c/ossia-sdk-msvc/ffmpeg 

/d/msys64/clang64/bin/mingw32-make.exe -j1
/d/msys64/clang64/bin/mingw32-make.exe install
