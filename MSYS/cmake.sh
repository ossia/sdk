#!/bin/bash -eux

source ./common.sh
source ../common/clone-cmake.sh

if [[ ! -d "$INSTALL_PREFIX/cmake" ]]; then
  curl -ksSL "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-$CMAKE_WIN_ARCH.zip" -o cmake.zip
  unzip cmake.zip
  mv "cmake-$CMAKE_VERSION-windows-$CMAKE_WIN_ARCH" "$INSTALL_PREFIX/cmake"

  rm -rf "$INSTALL_PREFIX/cmake/doc"
  rm -rf "$INSTALL_PREFIX/cmake/man"
fi

# Python is only needed by the Qt build and is provided by MSYS2 (deps.sh installs
# mingw-w64-<toolchain>-python). Reuse whatever 'python' is on PATH instead of
# installing our own -- the python.org installer is interactive (-quiet is broken,
# bpo-42192) and cannot run headless. meson likewise comes from pacman.
if ! command -v python >/dev/null 2>&1 && [[ ! -f "$INSTALL_PREFIX/python/python.exe" ]]; then
  echo "No 'python' found on PATH. Install the MSYS2 mingw python"
  echo "(pacman -S mingw-w64-\${TOOLCHAIN}-python, see deps.sh), then re-run:"
  echo "Qt's build requires it."
  exit 1
fi

if [[ ! -f "$TOOLS_ROOT/pkg-config.exe" ]]; then
(
  git clone $SDK_CLONE_DEPTH https://github.com/skeeto/u-config || true

  cd u-config
  # upstream renamed the entry point: win32_main.c -> main_windows.c
  $CC -O2 -nostartfiles -o "$TOOLS_ROOT/pkg-config.exe" main_windows.c
)
fi