#!/bin/bash -eux

source ./common.sh
source ../common/clone-cmake.sh

if [[ ! -d "$INSTALL_PREFIX/cmake" ]]; then
  curl -L "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.zip" -o cmake.zip
  unzip cmake.zip
  mv "cmake-$CMAKE_VERSION-windows-x86_64" "$INSTALL_PREFIX/cmake"

  sed -i '140 i 
  string(REGEX REPLACE "\\\\\\\\" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}")
  string(REGEX REPLACE "\\\\" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}")
  string(REGEX REPLACE "//" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}")
' "$INSTALL_PREFIX/cmake/share/cmake-$CMAKE_VERSION_SHORT/Modules/FindPkgConfig.cmake"
fi

if [[ ! -f "$INSTALL_PREFIX/python/python.exe" ]]; then
  curl -L https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-amd64.exe -o python.exe
  ./python.exe -quiet -TargetDir="$INSTALL_PREFIX_WIN32\\python"
  rm python.exe

  python -m ensurepip --upgrade
  python -m pip install meson
fi

if [[ ! -f "$TOOLS_ROOT/pkg-config.exe" ]]; then
(
  git clone https://github.com/skeeto/u-config

  cd u-config
  $CC -O2 -nostartfiles -o "$TOOLS_ROOT/pkg-config.exe" win32_main.c
)
fi