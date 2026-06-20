#!/bin/bash
# Downloads the prebuilt llvm-mingw cross toolchain pinned in versions.sh
# (LLVM_MINGW_VERSION) and installs it to $INSTALL_PREFIX/llvm, which the MSYS
# build expects to provide the x86_64-w64-mingw32 clang + runtime.
# Requires $INSTALL_PREFIX to be set by the caller (source common.sh first).

source ../common/versions.sh

# llvm-mingw toolchains are multi-target (every host ships all target subdirs),
# so the host arch only matters for which prebuilt to run natively. Match the
# build target (TARGET_ARCH, default x86_64).
case "${TARGET_ARCH:-x86_64}" in
  arm64|aarch64) LLVM_MINGW_HOST_ARCH=aarch64 ;;
  *)             LLVM_MINGW_HOST_ARCH=x86_64  ;;
esac

if [[ -x "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  echo "llvm-mingw already installed at $INSTALL_PREFIX/llvm"
else
  case "$OSTYPE" in
    linux*)   LLVM_MINGW_PKG="llvm-mingw-$LLVM_MINGW_VERSION-ucrt-ubuntu-22.04-$LLVM_MINGW_HOST_ARCH"; LLVM_MINGW_EXT="tar.xz" ;;
    darwin*)  LLVM_MINGW_PKG="llvm-mingw-$LLVM_MINGW_VERSION-ucrt-macos-universal";                   LLVM_MINGW_EXT="tar.xz" ;;
    *)        LLVM_MINGW_PKG="llvm-mingw-$LLVM_MINGW_VERSION-ucrt-$LLVM_MINGW_HOST_ARCH";             LLVM_MINGW_EXT="zip"    ;; # msys/mingw/cygwin -> windows
  esac

  (
    rm -rf "$LLVM_MINGW_PKG"
    curl -ksSLOJ "https://github.com/mstorsjo/llvm-mingw/releases/download/$LLVM_MINGW_VERSION/$LLVM_MINGW_PKG.$LLVM_MINGW_EXT"

    if [[ "$LLVM_MINGW_EXT" == "zip" ]]; then
      unzip -q "$LLVM_MINGW_PKG.$LLVM_MINGW_EXT"
    else
      tar xf "$LLVM_MINGW_PKG.$LLVM_MINGW_EXT"
    fi

    mkdir -p "$INSTALL_PREFIX"
    rm -rf "$INSTALL_PREFIX/llvm"
    mv "$LLVM_MINGW_PKG" "$INSTALL_PREFIX/llvm"
    rm -f "$LLVM_MINGW_PKG.$LLVM_MINGW_EXT"
  )
fi
