#!/bin/bash -eux

source ./common.sh

if [[ ! -d faust ]]; then
  git clone --recursive -j4 https://github.com/grame-cncm/faust
fi

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

export PATH=$INSTALL_PREFIX/llvm-libs/bin:$PATH
echo $PATH
# which llvm-config

cmake -G Ninja -C ../backends/llvm.cmake ..  \
  -DCMAKE_C_FLAGS="$CFLAGS -DFAUSTFLOAT=double" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS -DFAUSTFLOAT=double" \
  -DCMAKE_BUILD_TYPE=Release \
  -DINCLUDE_OSC=0 \
  -DINCLUDE_HTTP=0 \
  -DINCLUDE_EXECUTABLE=0 \
  -DINCLUDE_STATIC=1 \
  -DUSE_LLVM_CONFIG=0 \
  -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX_CMAKE/llvm-libs \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX_CMAKE/faust

#  -DLLVM_CONFIG=$INSTALL_PREFIX_CMAKE/llvm-libs/bin/llvm-config.exe \

cmake --build .
cmake --build . --target install/strip
