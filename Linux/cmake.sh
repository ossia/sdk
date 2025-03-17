#!/bin/bash -eux

source ./common.sh clang
source ../common/clone-cmake.sh

if [[ ! -d cmake ]]; then
  (
    curl -ksSLOJ https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-$ARCH.tar.gz
    tar xaf cmake-$CMAKE_VERSION-linux-$ARCH.tar.gz
    rm cmake-$CMAKE_VERSION-linux-$ARCH.tar.gz
    mv cmake-$CMAKE_VERSION-linux-$ARCH cmake
    
    if [[ "$ARCH" == "x86_64" ]]; then
      curl -ksSLOJ https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
      unzip ninja-linux.zip
    else
      curl -ksSLOJ https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux-aarch64.zip
      unzip ninja-linux-aarch64.zip
    fi
    mv -f ninja /usr/bin
  )
fi
