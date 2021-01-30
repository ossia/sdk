#!/bin/bash
export MACOS_VERSION=10.13
export MACOS_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.0.sdk
export NPROC=$(sysctl -n hw.logicalcpu)
export INSTALL_PREFIX=/opt/ossia-sdk
export SDK_ROOT=$PWD

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
fi

export CFLAGS="-O3 -mmacosx-version-min=$MACOS_VERSION -march=ivybridge -mtune=haswell"
export CXXFLAGS="-O3 -mmacosx-version-min=$MACOS_VERSION -march=ivybridge -mtune=haswell"
