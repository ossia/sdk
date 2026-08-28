#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk-wasm
export SDK_ROOT=$PWD
export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)

export CFLAGS="  -O3 -g0 -sABORTING_MALLOC=1 -pthread -sWASM_BIGINT=1 -sASSERTIONS=0 -sSAFE_HEAP=0 -sSTACK_OVERFLOW_CHECK=0 -sFETCH=1 -pthread -fnew-infallible -fno-plt -fno-semantic-interposition -msimd128 -mrelaxed-simd  -fwasm-exceptions "
export CXXFLAGS="-O3 -g0 -sABORTING_MALLOC=1 -pthread -sWASM_BIGINT=1 -sASSERTIONS=0 -sSAFE_HEAP=0 -sSTACK_OVERFLOW_CHECK=0 -sFETCH=1 -pthread -fnew-infallible -fno-plt -fno-semantic-interposition -msimd128 -mrelaxed-simd -fwasm-exceptions "
export LDFLAGS=" -O3 -g0 -sABORTING_MALLOC=1 -pthread -sWASM_BIGINT=1 -sASSERTIONS=0 -sSAFE_HEAP=0 -sSTACK_OVERFLOW_CHECK=0 -sFETCH=1 -pthread -fnew-infallible -fno-plt -fno-semantic-interposition -msimd128 -mrelaxed-simd  -fwasm-exceptions "

if [[ -f "$INSTALL_PREFIX/emsdk/emsdk_env.sh" ]]; then
  source "$INSTALL_PREFIX/emsdk/emsdk_env.sh"
fi

# Shared upstream version pins (EMSDK_VERSION, QT_VERSION, FFMPEG_VERSION,
# LLVM_VERSION, ...). 'common' is a symlink to ../common inside WASM/. Sourced
# AFTER emsdk_env.sh on purpose: emsdk's construct_env clears any EMSDK_* var it
# manages (incl. EMSDK_VERSION), so our pin must be set last to survive.
source "$SDK_ROOT/common/versions.sh"
