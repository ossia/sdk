#!/bin/bash -eux

mkdir -p qt6-build-host
(
  # The host Qt tools build with the NATIVE compiler, so the emscripten target
  # flags exported by common.sh (inherited here from all.sh) must not leak into
  # it -- c++ rejects -sABORTING_MALLOC, -fwasm-exceptions, -msimd128, ...
  # Only the wasm build below (which re-sources common.sh) gets them.
  unset CFLAGS CXXFLAGS LDFLAGS
  cd qt6-build-host
  ../qt/configure \
     -skip qtwayland \
     -skip qtserialport \
     -skip qtsvg \
     -skip qtimageformats \
     -skip qtmultimedia \
     -skip qtquick3d \
     -skip qtquicktimeline \
     -skip qtquick3dphysics \
     -release \
     -nomake tests \
     -nomake examples \
     -cmake-generator Ninja \
     -no-feature-zstd \
     -no-rpath \
     -no-intelcet \
     -no-glibc-fortify-source \
     -no-stack-protector \
     -no-stack-clash-protection \
     -no-relro-now-linker \
     -prefix /opt/ossia-sdk-wasm/qt6-host
  ninja
  ninja install
)

source ./common.sh

mkdir -p qt6-build-static
(
  cd qt6-build-static
  ../qt/configure \
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
     -feature-wasm-jspi -feature-wasm-exceptions \
     -feature-wasm-simd128 \
     -feature-opengles3 \
     -no-feature-zstd \
     -qt-host-path /opt/ossia-sdk-wasm/qt6-host \
     -platform wasm-emscripten 
  cmake .  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DCMAKE_CXX_STANDARD=23
  ninja
  ninja install
)
