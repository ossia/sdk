#!/bin/bash -eux

mkdir -p qt6-build-host
(
  cd qt6-build-host
  ../qt6/configure \
     -skip qtwayland \
     -skip qtserialport \
     -skip qtwebsockets \
     -skip qtsvg \
     -skip qtimageformats \
     -release \
     -nomake tests \
     -nomake examples \
     -cmake-generator Ninja \
     -no-feature-zstd \
     -prefix /opt/ossia-sdk-wasm/qt6-host -- -DBUILD_qtwebsockets=ON 
  ninja
  ninja install
)

source ./common.sh

mkdir -p qt6-build-static
(
  cd qt6-build-static
  ../qt6/configure \
     -skip qtwayland \
     -skip qtserialport \
     -skip qtsvg \
     -skip qtimageformats \
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
     -device-option QT_EMSCRIPTEN_ASYNCIFY=1 -- -DBUILD_qtwebsockets=ON 
  ninja
  ninja install
)