#!/bin/bash

source ./common.sh

if [[ ! -d zlib-ng ]]; then
  git clone https://github.com/zlib-ng/zlib-ng
fi

mkdir -p zlib-build
cd zlib-build

cmake \
 -DCMAKE_BUILD_TYPE=Release \
 -G"Ninja" \
 -DZLIB_COMPAT=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/zlib" \
 ../zlib-ng

cmake --build . --config Release
cmake --build . --config Release --target install
