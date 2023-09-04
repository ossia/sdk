#!/bin/bash -eux
export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

source "$SDK_COMMON_ROOT/common/clone-qt.sh"

mkdir -p qt6-build-static
(
  cd qt6-build-static
  # note: need to do it twice for qtbase to get cxx_standard=20
  ../qt/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -opengl desktop \
                   -feature-schannel \
                   -no-feature-vnc \
                   -system-freetype \
                   -system-harfbuzz \
                   -prefix $INSTALL_PREFIX_CMAKE/qt6-static \
                   -- \
                   -DCMAKE_C_FLAGS="$CFLAGS" \
                   -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
                   -DCMAKE_CXX_STANDARD=20 \
                   -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX_CMAKE \
                   -DFREETYPE_DIR=$INSTALL_PREFIX_CMAKE/freetype \
                   -DZLIB_ROOT=$INSTALL_PREFIX_CMAKE/zlib \
                   -Dharfbuzz_DIR=$INSTALL_PREFIX_CMAKE/harfbuzz \
                   -DHARFBUZZ_INCLUDE_DIRS=$INSTALL_PREFIX_CMAKE/harfbuzz/include \
                   -DHARFBUZZ_LIBRARIES=$INSTALL_PREFIX_CMAKE/harfbuzz/lib/libharfbuzz.a

  cmake --build . -- -j1 -k 0
  cmake --build . --target install
)
