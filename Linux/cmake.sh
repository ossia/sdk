#!/bin/bash -eu

source ../common/clone-cmake.sh

if [[ ! -d cmake ]]; then
(
  wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
  tar xaf cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
  rm cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
  mv cmake-$CMAKE_VERSION-linux-x86_64 cmake
  
  wget https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
  unzip ninja-linux.zip
  mv -f ninja /usr/bin
)
fi