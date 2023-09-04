#!/bin/bash

source ./common.sh

export TOOLCHAIN=clang-x86_64
PACKAGES=(
mingw-w64-$TOOLCHAIN-zlib
mingw-w64-$TOOLCHAIN-cmake
mingw-w64-$TOOLCHAIN-toolchain
mingw-w64-$TOOLCHAIN-cppwinrt
mingw-w64-$TOOLCHAIN-meson
mingw-w64-$TOOLCHAIN-vulkan-headers
mingw-w64-$TOOLCHAIN-git
wget
diffutils
yasm
tar
unzip
git
)

pacman -S  "${PACKAGES[@]}"

SDK_DIR=.