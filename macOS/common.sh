#!/bin/bash
export MACOS_VERSION=11.0
export MACOS_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
export NPROC=$(sysctl -n hw.logicalcpu)
export SDK_ROOT=$PWD

export MACOS_ARCH=$(uname -m)
if [[ "$MACOS_ARCH" == "arm64" ]]; then
  export CPUFLAGS=" -mcpu=apple-m1 "
  export INSTALL_PREFIX=/opt/ossia-sdk-aarch64
else
  export CPUFLAGS=" -march=ivybridge -mtune=cannonlake "
  export INSTALL_PREFIX=/opt/ossia-sdk-x86_64
fi

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
fi

export CMAKE_ADDITIONAL_FLAGS="-DCMAKE_OSX_ARCHITECTURES=$MACOS_ARCH -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT"
export CFLAGS="-O3 -mmacosx-version-min=$MACOS_VERSION $CPUFLAGS -Ofast -fno-finite-math-only "
export CXXFLAGS="-O3 -mmacosx-version-min=$MACOS_VERSION $CPUFLAGS -Ofast -fno-finite-math-only "

alias tar=gtar
alias sed=gsed

source ../common/versions.sh
