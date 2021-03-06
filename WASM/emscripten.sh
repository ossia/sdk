#!/bin/bash

source common.sh

mkdir -p $INSTALL_PREFIX
cd $INSTALL_PREFIX
git clone https://github.com/emscripten-core/emsdk.git

cd emsdk
./emsdk install 2.0.14
./emsdk activate 2.0.14
