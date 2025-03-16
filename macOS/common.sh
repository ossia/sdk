#!/bin/bash -eux
export MACOS_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
export NPROC=$(sysctl -n hw.logicalcpu)
export SDK_ROOT=$PWD

export MACOS_ARCH=$(uname -m)
export MACOS_VERSION=12.0

 is_sourced() {
   if [[ -n "${ZSH_VERSION:-}" ]]; then 
       case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
   else  # Add additional POSIX-compatible shell names here, if needed.
       case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
   fi
   return 1  # NOT sourced.
 }
 is_sourced && sourced=1 || sourced=0

if [[ -z "${TARGET_ARCH:-}" ]]; then
  echo "TARGET_ARCH must be set to arm64 or x86_64"
  if [[ "${sourced}" -eq "1" ]]; then
    return
  else
    exit 1
  fi
fi

if [[ "$TARGET_ARCH" == "arm64" ]]; then
  export CPU_TARGET="apple-m1"
  export CPUFLAGS=" -mcpu=$CPU_TARGET -arch arm64 "
  export INSTALL_PREFIX=/opt/ossia-sdk-aarch64
  export LLVM_ARCH=AArch64
else
  # 2025-03: apple silicon still does not support x86_64h and some instruction sets such as f16c and rdrand
  export CPU_TARGET="x86-64-v2"
  export CPUFLAGS=" -mtune=cannonlake -arch x86_64 -arch x86_64h "
  export INSTALL_PREFIX=/opt/ossia-sdk-x86_64
  export LLVM_ARCH=X86
fi

if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
else
  export CC=clang
  export CXX=clang++
fi

export CMAKE_ADDITIONAL_FLAGS="-DCMAKE_OSX_ARCHITECTURES=$TARGET_ARCH -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT"
export CFLAGS=" -mmacosx-version-min=$MACOS_VERSION $CPUFLAGS -Ofast -fno-finite-math-only "
export CFLAGS_NOARCH=" -mmacosx-version-min=$MACOS_VERSION -Ofast -fno-finite-math-only "
export CXXFLAGS=" -mmacosx-version-min=$MACOS_VERSION $CPUFLAGS -Ofast -fno-finite-math-only "

alias tar=gtar
alias sed=gsed

source ../common/versions.sh
