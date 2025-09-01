#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk-wasm
export SDK_ROOT=$PWD
export CFLAGS="-O3 -g0 -sABORTING_MALLOC=1 -sWEBGL2_BACKWARDS_COMPATIBILITY_EMULATION=1 -sMAX_WEBGL_VERSION=2 -sWASM_BIGINT=1 -sASSERTIONS=0 -sSAFE_HEAP=0 -sUSE_PTHREADS -flto -fnew-infallible -fno-plt -fno-semantic-interposition "
export CXXFLAGS="-O3 -g0 -sABORTING_MALLOC=1 -sWEBGL2_BACKWARDS_COMPATIBILITY_EMULATION=1 -sMAX_WEBGL_VERSION=2 -sWASM_BIGINT=1 -sASSERTIONS=0 -sSAFE_HEAP=0 -sUSE_PTHREADS -flto -fnew-infallible -fno-plt -fno-semantic-interposition "
export LDFLAGS="-O3 -g0 -sABORTING_MALLOC=1 -sWEBGL2_BACKWARDS_COMPATIBILITY_EMULATION=1 -sMAX_WEBGL_VERSION=2 -sWASM_BIGINT=1 -sASSERTIONS=0 -sSAFE_HEAP=0 -sUSE_PTHREADS -flto -fnew-infallible -fno-plt -fno-semantic-interposition "

if [[ -f "$INSTALL_PREFIX/emsdk/emsdk_env.sh" ]]; then
  source "$INSTALL_PREFIX/emsdk/emsdk_env.sh"
fi