#!/bin/bash -eux
export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

source "$SDK_COMMON_ROOT/common/clone-qt.sh"

mkdir -p qt6-build-static
(
  cd qt6-build-static
  ../qt/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -opengl desktop \
                   -feature-schannel \
                   -no-feature-vnc \
                   -no-feature-zstd \
                   -prefix $INSTALL_PREFIX/qt6-static \
                   -- \
                   -DCMAKE_C_FLAGS="$CFLAGS" \
                   -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
                   -DCMAKE_CXX_STANDARD=20 \
                   -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
                   -DFREETYPE_DIR=$INSTALL_PREFIX/freetype

  cmake --build . -- -j1 -k 0
  cmake --build . --target install
)
