#!/bin/bash -e
# -e: stop on the first failing step instead of silently packaging an incomplete
# SDK (this build has no other error checking between steps).

# Drives the full Windows/MSYS2 build. Honours TARGET_ARCH (x86_64 | arm64),
# which common.sh maps to the install prefix, toolchain and triple.
source ./common.sh

# Prerequisites are now automated (run ./deps.sh first):
#  - toolchain/python/meson/perl/nasm/cppwinrt/vulkan-headers : deps.sh (pacman)
#  - cppwinrt + vulkan headers copied into the toolchain        : llvm-deps.sh
#  - pkg-config (u-config) and /c/gnu/bin                       : cmake.sh / common.sh
# Note: fftw's configure must use the MSYS2 /usr/bin/sh, not Git-for-Windows'
# "C:/Program Files/Git/.../sh.exe" (spaces break autotools); the default MSYS2
# PATH ordering handles this as long as we do not inherit the runner PATH.

./cmake.sh
./zlib.sh
./freetype.sh
./llvm-deps.sh
./llvm.sh
./qt.sh
./ffmpeg.sh
./fftw.sh
./portaudio.sh
./sdl.sh
./faust.sh
./jack.sh
./dnssd.sh
./ysfx.sh

cd $INSTALL_PREFIX
7z a "$SDK_ROOT/sdk-mingw-$SDK_ARCH.7z" *

