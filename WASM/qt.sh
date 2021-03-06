#!/bin/bash -eux
source ./common.sh

mkdir -p qt5-build-static
(
  cd qt5-build-static

  ../qt5/configure $(cat "$SDK_ROOT/common/qtfeatures") \
                   -xplatform wasm-emscripten \
                   -no-warnings-are-errors \
                   -prefix $INSTALL_PREFIX/qt5

  make -j$NPROC
  make install -j$NPROC
)
exit 0
(
  cd qt5
  git clone https://github.com/jcelerier/qtshadertools.git
  cd qtshadertools
  $INSTALL_PREFIX/qt5/bin/qmake
  make -j$NPROC
  make install -j$NPROC
)
