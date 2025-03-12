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
git
wget
diffutils
yasm
tar
unzip
git
)

pacman -S --needed "${PACKAGES[@]}"

mkdir -p $INSTALL_PREFIX/sysroot/include
SDK_DIR=.