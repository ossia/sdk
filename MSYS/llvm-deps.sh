#!/bin/bash

source ./common.sh
# Install the prebuilt llvm-mingw cross toolchain into $INSTALL_PREFIX/llvm
# (provides x86_64-w64-mingw32 clang + runtime used by the rest of the build).
source ../common/clone-llvm-mingw.sh
