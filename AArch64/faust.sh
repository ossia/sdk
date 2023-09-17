#!/bin/bash

source ./common.sh clang

if [[ ! -d faust ]] ;
then
$GIT clone --depth=1 https://github.com/grame-cncm/faust -b master-dev
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

sed -i 's/no-rtti/rtti/g' CMakeLists.txt

mkdir -p faustdir
cd faustdir

$CMAKE -GNinja \
    -C ../backends/llvm.cmake \
    -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
    -DINCLUDE_OSC=0 \
    -DINCLUDE_HTTP=0 \
    -DINCLUDE_EXECUTABLE=0 \
    -DINCLUDE_STATIC=1 \
    -DUSE_LLVM_CONFIG=0 \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX/llvm-libs \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/faust \
    -DLLVM_STATIC_LINK_CXX_STDLIB=1 \
    ..

$CMAKE --build .
$CMAKE --build . --target install/strip
