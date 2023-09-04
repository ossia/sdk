#!/bin/bash

source ./common.sh

export TOOLCHAIN=clang-x86_64
pacman -S mingw-w64-$TOOLCHAIN-zlib mingw-w64-$TOOLCHAIN-cmake mingw-w64-$TOOLCHAIN-git wget diffutils yasm tar unzip

SDK_DIR=.