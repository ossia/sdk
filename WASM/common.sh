#!/bin/bash

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk-wasm
export SDK_ROOT=$PWD
export CFLAGS="-O3 -g0"
export CXXFLAGS="-O3 -g0"

if [[ -f "$INSTALL_PREFIX/emsdk/emsdk_env.sh" ]]; then
  source "$INSTALL_PREFIX/emsdk/emsdk_env.sh"
fi