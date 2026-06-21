#!/bin/bash

source ./common.sh

export TOOLCHAIN=$MSYS2_TOOLCHAIN
PACKAGES=(
mingw-w64-$TOOLCHAIN-zlib
mingw-w64-$TOOLCHAIN-cmake
mingw-w64-$TOOLCHAIN-toolchain
mingw-w64-$TOOLCHAIN-cppwinrt
mingw-w64-$TOOLCHAIN-meson
mingw-w64-$TOOLCHAIN-python
mingw-w64-$TOOLCHAIN-vulkan-headers
mingw-w64-$TOOLCHAIN-nasm
mingw-w64-$TOOLCHAIN-ccache
mingw-w64-$TOOLCHAIN-7zip
git
wget
diffutils
yasm
perl
tar
unzip
)

# --noconfirm is required in CI: without it pacman blocks on the [Y/n] prompt,
# reads EOF on stdin and aborts, installing nothing (no toolchain/python/meson).
pacman -S --needed --noconfirm "${PACKAGES[@]}"

mkdir -p $INSTALL_PREFIX/sysroot/include
SDK_DIR=.