#!/bin/bash

source ./common.sh
# Install the prebuilt llvm-mingw cross toolchain into $INSTALL_PREFIX/llvm
# (provides x86_64-w64-mingw32 clang + runtime used by the rest of the build).
source ../common/clone-llvm-mingw.sh

# Qt's cpp-winrt and vulkan feature compile-tests use the llvm-mingw toolchain,
# which does not search $MSYSTEM_PREFIX/include. Copy the headers Qt needs from
# the MSYS2 cppwinrt + vulkan-headers packages into the toolchain (these were
# manual steps / a separately-installed Vulkan SDK before).
if [[ -d "$MSYSTEM_PREFIX/include/winrt" ]]; then
  cp -rf "$MSYSTEM_PREFIX/include/winrt" "$INSTALL_PREFIX/llvm/include/"
fi
if [[ -f "$MSYSTEM_PREFIX/lib/libruntimeobject.a" ]]; then
  cp -f "$MSYSTEM_PREFIX/lib/libruntimeobject.a" "$INSTALL_PREFIX/llvm/$MINGW_TRIPLE/lib/"
fi
for d in vulkan vk_video; do
  if [[ -d "$MSYSTEM_PREFIX/include/$d" ]]; then
    cp -rf "$MSYSTEM_PREFIX/include/$d" "$INSTALL_PREFIX/llvm/include/"
  fi
done
