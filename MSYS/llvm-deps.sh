#!/bin/bash

source ./common.sh
# Install the prebuilt llvm-mingw cross toolchain into $INSTALL_PREFIX/llvm
# (provides x86_64-w64-mingw32 clang + runtime used by the rest of the build).
source ../common/clone-llvm-mingw.sh

# Qt's cpp-winrt feature compile-test needs the C++/WinRT headers and
# libruntimeobject in the llvm-mingw toolchain. They ship in the MSYS2 cppwinrt
# package (under $MSYSTEM_PREFIX); copy them in (previously a manual step).
if [[ -d "$MSYSTEM_PREFIX/include/winrt" ]]; then
  cp -rf "$MSYSTEM_PREFIX/include/winrt" "$INSTALL_PREFIX/llvm/include/"
fi
if [[ -f "$MSYSTEM_PREFIX/lib/libruntimeobject.a" ]]; then
  cp -f "$MSYSTEM_PREFIX/lib/libruntimeobject.a" "$INSTALL_PREFIX/llvm/$MINGW_TRIPLE/lib/"
fi
