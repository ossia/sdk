#!/bin/bash

source /image/config.sh

# This image is built from the ARM/RPi2 docker context, which cannot reach
# ../../common, so the pin and the pick list are repeated here. Keep them in
# sync with FAUST_VERSION / FAUST_PRS in common/versions.sh.
FAUST_REPO=https://github.com/grame-cncm/faust
FAUST_VERSION=2e20dde10938821e68395f5e25e8414c6767f13e
FAUST_PRS="1281"

## Faust
(
set -e
export PATH=/cmake/bin:$PATH
git clone --depth=1 "$FAUST_REPO"
cd faust
git fetch --depth 2 origin "$FAUST_VERSION"
git checkout "$FAUST_VERSION"
git submodule update --init --recursive
git config user.email "you@example.com"
git config user.name "Your Name"
for pr in $FAUST_PRS; do
  echo "faust: applying PR #$pr"
  git fetch --depth 2 "$FAUST_REPO" "refs/pull/$pr/head"
  git cherry-pick --keep-redundant-commits FETCH_HEAD
done
cd build
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
make -j$(nproc)
make install
)