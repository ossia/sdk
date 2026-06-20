#!/bin/bash -eux

source ./common.sh
source ../common/clone-cmake.sh

if [[ ! -d "$INSTALL_PREFIX/cmake" ]]; then
  curl -ksSL "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.zip" -o cmake.zip
  unzip cmake.zip
  mv "cmake-$CMAKE_VERSION-windows-x86_64" "$INSTALL_PREFIX/cmake"

  rm -rf "$INSTALL_PREFIX/cmake/doc"
  rm -rf "$INSTALL_PREFIX/cmake/man"
fi

# Python is only needed by the Qt build. CI runners (and MSYS2) already provide
# one, so reuse whatever is on PATH instead of installing our own. The python.org
# installer is interactive (-quiet is broken, bpo-42192) and cannot run headless.
# meson is provided by pacman (see deps.sh), so no pip step is needed here.
if ! command -v python >/dev/null 2>&1 && [[ ! -f "$INSTALL_PREFIX/python/python.exe" ]]; then
  echo "No 'python' found on PATH. Install one (e.g. 'pacman -S python', or use"
  echo "the GitHub runner's pre-installed Python via setup-msys2 path-type: inherit),"
  echo "then re-run: Qt's build requires it."
  exit 1
fi

if [[ ! -f "$TOOLS_ROOT/pkg-config.exe" ]]; then
(
  git clone https://github.com/skeeto/u-config || true

  cd u-config
  $CC -O2 -nostartfiles -o "$TOOLS_ROOT/pkg-config.exe" win32_main.c
)
fi