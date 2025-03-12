#!/bin/bash -eux

source ./common.sh
source ../common/clone-cmake.sh

if [[ ! -d "$INSTALL_PREFIX/cmake" ]]; then
  curl -ksSL "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.zip" -o cmake.zip
  unzip cmake.zip
  mv "cmake-$CMAKE_VERSION-windows-x86_64" "$INSTALL_PREFIX/cmake"

  #In macro(_pkgconfig_invoke (line 156 for cmake-3.31)
  sed -ri '156i \
    string(REGEX REPLACE "\\\\\\\\\\\\\\\\" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}") \
    string(REGEX REPLACE "\\\\\\\\" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}") \
    string(REGEX REPLACE "\\\\" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}") \
    string(REGEX REPLACE "//" "/" _pkgconfig_invoke_result "${_pkgconfig_invoke_result}") \
' "$INSTALL_PREFIX/cmake/share/cmake-$CMAKE_VERSION_SHORT/Modules/FindPkgConfig.cmake"
  rm -rf "$INSTALL_PREFIX/cmake/doc"
  rm -rf "$INSTALL_PREFIX/cmake/man"
fi

if [[ ! -f "$INSTALL_PREFIX/python/python.exe" ]]; then
  curl -ksSL https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-amd64.exe -o python.exe
  # https://bugs.python.org/issue42192
  ./python.exe -uninstall -quiet
  echo "Install python from GUI as -quiet does not work"
  exit 1
  # ./python.exe -quiet InstallAllUsers=1 PrependPath=1 -TargetDir="$INSTALL_PREFIX_WIN32\\python"
  rm python.exe

  $INSTALL_PREFIX/python/python -m ensurepip --upgrade
  $INSTALL_PREFIX/python/python -m pip install meson
fi

if [[ ! -f "$TOOLS_ROOT/pkg-config.exe" ]]; then
(
  git clone https://github.com/skeeto/u-config || true

  cd u-config
  $CC -O2 -nostartfiles -o "$TOOLS_ROOT/pkg-config.exe" win32_main.c
)
fi