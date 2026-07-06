#!/bin/bash -eux

source ./common.sh   # provides $EMSDK_VERSION (from common/versions.sh)

mkdir -p "$INSTALL_PREFIX"
cd "$INSTALL_PREFIX"
if [[ ! -d emsdk ]]; then
  git clone https://github.com/emscripten-core/emsdk.git
fi

cd emsdk
git pull
./emsdk install "$EMSDK_VERSION"
./emsdk activate "$EMSDK_VERSION"
