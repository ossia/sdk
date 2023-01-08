#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk-wasm
export SDK_ROOT=$PWD
export CFLAGS="-O3 -g0 -s USE_PTHREADS"
export CXXFLAGS="-O3 -g0 -s USE_PTHREADS"
export LDFLAGS="-O3 -g0 -s USE_PTHREADS"

if [[ -f "$INSTALL_PREFIX/emsdk/emsdk_env.sh" ]]; then
  source "$INSTALL_PREFIX/emsdk/emsdk_env.sh"
fi