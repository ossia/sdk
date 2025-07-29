#!/bin/bash -eux
source ./common.sh
export PATH=/c/Perl64/perl/bin:/c/ossia-sdk-x86_64/python:$PATH

source "$SDK_COMMON_ROOT/common/clone-qt.sh"

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"

mkdir -p qt6-build-static
(
  cd qt6-build-static
  # note: need to do it twice for qtbase to get cxx_standard=20
  ../qt/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -opengl desktop \
                   -feature-cpp-winrt \
                   -feature-vulkan \
                   -feature-schannel \
                   -no-feature-vnc \
                   -system-freetype \
                   -system-harfbuzz \
                   -unity-build \
                   -prefix "$INSTALL_PREFIX_CMAKE/qt6-static" \
                   -disable-deprecated-up-to 0x060800 \
                   -- \
                   -DCMAKE_C_FLAGS="$CFLAGS" \
                   -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
                   -DCMAKE_CXX_STANDARD=20 \
                   -DCMAKE_EXE_LINKER_FLAGS="$INSTALL_PREFIX_CMAKE/sysroot/lib/libbrotlidec.a $INSTALL_PREFIX_CMAKE/sysroot/lib/libbrotlicommon.a " \
                   -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX_CMAKE;$INSTALL_PREFIX_CMAKE/sysroot;$INSTALL_PREFIX_CMAKE/sysroot/lib/cmake" \
                   -DFREETYPE_DIR="$INSTALL_PREFIX_CMAKE/sysroot" \
                   -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot" \
                   -Dharfbuzz_DIR="$INSTALL_PREFIX_CMAKE/sysroot" \
                   -DHARFBUZZ_INCLUDE_DIRS="$INSTALL_PREFIX_CMAKE/sysroot/include" \
                   -DHARFBUZZ_LIBRARIES="$INSTALL_PREFIX_CMAKE/sysroot/lib/libharfbuzz.a"

  # For qtcore to pick up cmake_cxx_standard
  cmake .
  cmake --build . -- -k 0
  # cmake --build . -- -j1 -k 0
  cmake --build . --target install/strip
)
