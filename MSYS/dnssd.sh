#!/bin/bash

source ./common.sh

if [[ ! -d dnssd ]]; then
  git clone https://github.com/jcelerier/dnssd
fi

mkdir -p dnssd-build
cd dnssd-build

cmake \
 -DCMAKE_BUILD_TYPE=Release \
 -G"Ninja" \
 -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/dnssd" \
 ../dnssd

cmake --build . --config Release
cmake --build . --config Release --target install
