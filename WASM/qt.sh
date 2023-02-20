#!/bin/bash -eux

mkdir -p qt6-build-host
(
  cd qt6-build-host
  ../qt6/configure \
     -release \
     -nomake tests \
     -nomake examples \
     -cmake-generator Ninja \
     -no-feature-zstd \
     -prefix /opt/ossia-sdk-wasm/qt6-host
  ninja
  ninja install
)

source ./common.sh

mkdir -p qt6-build-static
(
  cd qt6-build-static
  ../qt6/configure \
     -release \
     -nomake tests \
     -nomake examples \
     -cmake-generator Ninja \
     -prefix /opt/ossia-sdk-wasm/qt-wasm \
     -feature-thread \
     -sse2 \
     -feature-opengles3 \
     -no-feature-zstd \
     -qt-host-path /opt/ossia-sdk-wasm/qt6-host \
     -platform wasm-emscripten \
     -device-option QT_EMSCRIPTEN_ASYNCIFY=1
  ninja
  ninja install
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
