#!/bin/bash

source /image/config.sh
## Faust
( 
export PATH=/cmake/bin:$PATH
git clone --depth=1 https://github.com/grame-cncm/faust
cd faust/build
echo '
set ( ASMJS_BACKEND  OFF CACHE STRING  "Include ASMJS backend" FORCE )
set ( C_BACKEND      COMPILER STATIC DYNAMIC        CACHE STRING  "Include C backend"         FORCE )
set ( CPP_BACKEND    COMPILER STATIC DYNAMIC        CACHE STRING  "Include CPP backend"       FORCE )
set ( FIR_BACKEND    OFF        CACHE STRING  "Include FIR backend"       FORCE )
set ( INTERP_BACKEND OFF        CACHE STRING  "Include INTERPRETER backend" FORCE )
set ( JAVA_BACKEND   OFF        CACHE STRING  "Include JAVA backend"      FORCE )
set ( JS_BACKEND     OFF        CACHE STRING  "Include JAVASCRIPT backend" FORCE )
set ( LLVM_BACKEND   COMPILER STATIC DYNAMIC        CACHE STRING  "Include LLVM backend"      FORCE )
set ( OLDCPP_BACKEND OFF        CACHE STRING  "Include old CPP backend"   FORCE )
set ( RUST_BACKEND   OFF        CACHE STRING  "Include RUST backend"      FORCE )
set ( WASM_BACKEND   OFF   CACHE STRING  "Include WASM backend"  FORCE )
' > backends/llvm.cmake
mkdir -p faustdir
cd faustdir
cmake -C ../backends/llvm.cmake  .. -DINCLUDE_OSC=0 -DINCLUDE_HTTP=0 -DINCLUDE_EXECUTABLE=0 -DINCLUDE_STATIC=1
BACKENDS=llvm.cmake make configstatic
make -j$(nproc)
make install
)
## FFMPEG
apt -y install  nasm
wget -nv https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2
tar -xaf ffmpeg-4.1.tar.bz2
cd ffmpeg-4.1
export CFLAGS="-O3 -mfpu=neon-vfpv4"
./configure --arch=armv7-a --cpu=cortex-a7 --disable-doc --disable-ffmpeg --disable-ffplay --disable-debug --prefix=/usr/local --pkg-config-flags="--static" --enable-gpl --enable-version3 --disable-openssl --disable-securetransport --disable-videotoolbox --disable-network --disable-iconv --disable-lzma
make -j$(nproc)
make install
cd ..

## PortAudio
apt install libasound2-dev
(
wget -nv http://www.portaudio.com/archives/pa_snapshot.tgz
tar xaf pa_snapshot.tgz

sed -i '378i TARGET_INCLUDE_DIRECTORIES(portaudio_static PUBLIC "$<INSTALL_INTERFACE:include>")' portaudio/CMakeLists.txt
sed -i '307d' portaudio/CMakeLists.txt # SET(PA_LIBRARY_DEPENDENCIES ${PA_LIBRARY_DEPENDENCIES} ${ALSA_LIBRARIES})
sed -i '306d' portaudio/CMakeLists.txt # SET(PA_PKGCONFIG_LDFLAGS "${PA_PKGCONFIG_LDFLAGS} -lasound")
sed -i '305d' portaudio/CMakeLists.txt

sed -i '305i  SET(PA_PRIVATE_COMPILE_DEFINITIONS ${PA_PRIVATE_COMPILE_DEFINITIONS} PA_USE_ALSA PA_ALSA_DYNAMIC)' portaudio/CMakeLists.txt
sed -i '305i  SET(PA_PKGCONFIG_LDFLAGS "${PA_PKGCONFIG_LDFLAGS} ${CMAKE_DL_LIBS}")' portaudio/CMakeLists.txt
      
      
cd portaudio/build

cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
 -DPA_BUILD_SHARED=Off \
 -DPA_USE_JACK=Off 

make -j$NPROC
make install
)
cd ../..
