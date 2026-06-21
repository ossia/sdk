#!/bin/bash

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
export NPROC=12

# Target arch: x86_64 (default) or arm64. Drives the install prefix, the MSYS2
# toolchain, the mingw triple and the cmake/llvm-mingw download arches.
export TARGET_ARCH=${TARGET_ARCH:-x86_64}
if [[ "$TARGET_ARCH" == "arm64" ]]; then
  export SDK_ARCH=aarch64
  export MINGW_TRIPLE=aarch64-w64-mingw32
  export MSYS2_TOOLCHAIN=clang-aarch64
  export CMAKE_WIN_ARCH=arm64
  export LLVM_ARCH=AArch64
  export ARCHFLAGS=""            # Windows-on-ARM baseline is ARMv8-A
else
  export SDK_ARCH=x86_64
  export MINGW_TRIPLE=x86_64-w64-mingw32
  export MSYS2_TOOLCHAIN=clang-x86_64
  export CMAKE_WIN_ARCH=x86_64
  export LLVM_ARCH=X86
  export ARCHFLAGS="-march=x86-64-v3"
fi

export INSTALL_PREFIX=/c/ossia-sdk-$SDK_ARCH
export INSTALL_PREFIX_CMAKE=c:/ossia-sdk-$SDK_ARCH
export INSTALL_PREFIX_WIN32=c:\\ossia-sdk-$SDK_ARCH
export SDK_ROOT=$PWD
export TOOLS_ROOT=/c/gnu/bin
mkdir -p "$TOOLS_ROOT"   # pkg-config.exe is built here; the dir must exist in CI

export CC=clang
export CXX=clang++
export CFLAGS="-O3 $ARCHFLAGS"
export CXXFLAGS="-O3 $ARCHFLAGS"
export LDFLAGS=""

export PATH="$INSTALL_PREFIX/cmake/bin:$INSTALL_PREFIX/python:$INSTALL_PREFIX/python/Scripts:$TOOLS_ROOT:$PATH:/c/Program Files/Meson"
if ! command -v mingw32-make &> /dev/null; then
  export MAKE=make
else
  export MAKE=mingw32-make
fi

source ../common/versions.sh
if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export CFLAGS="-O3 -fno-stack-protector -fnew-infallible "
  export CXXFLAGS="-O3 -fno-stack-protector -fnew-infallible "
fi

# ccache launcher for autotools/configure steps (ffmpeg, fftw); cmake steps use
# CMAKE_<LANG>_COMPILER_LAUNCHER (set in the workflow).
command -v ccache >/dev/null 2>&1 && export CCACHE_LAUNCHER="ccache" || export CCACHE_LAUNCHER=""

export CMAKE_BUILD_TYPE=Release
export MESON_BUILD_TYPE=release
export QT_MODE="release"
export LLVM_ADDITIONAL_FLAGS=" "

export MESON_COMMON_FLAGS=(
    -Dbuildtype=$MESON_BUILD_TYPE
    -Ddefault_library=static
    -Dglib=disabled
    -Dgobject=disabled
    -Dicu=disabled
    -Ddocs=disabled
    -Dtests=disabled
)
export CMAKE_COMMON_FLAGS=(
  -GNinja
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
)

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
