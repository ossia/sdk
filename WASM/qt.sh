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
     -skip qtconnectivity \
     -skip qtserialport \
     -skip qtmultimedia \
     -skip qtquick3d \
     -skip qtquicktimeline \
     -skip qtquick3dphysics \
     -release \
     -nomake tests \
     -nomake examples \
     -cmake-generator Ninja \
     -no-feature-zstd \
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
  # Safety net so the qt6-host tools (qlalr, moc, qmlcachegen, ...) invoked
  # during the cross-build always find their Qt libs even if rpath is off;
  # affects native host tools only, not the emcc/wasm output.
  export LD_LIBRARY_PATH="/opt/ossia-sdk-wasm/qt6-host/lib:${LD_LIBRARY_PATH:-}"
  cd qt6-build-static
  # Skip the same modules as the host build above: the wasm cross-build pulls
  # host tools (Qt6::balsam / Qt6Quick3DTools, QuickTimeline) from qt6-host, so
  # anything built here must also exist there. Quick3D/multimedia aren't needed
  # for the (audio-focused) wasm SDK.
  ../qt/configure \
     -skip qtwayland \
     -skip qtconnectivity \
     -skip qtserialport \
     -skip qtmultimedia \
     -skip qtquick3d \
     -skip qtquicktimeline \
     -skip qtquick3dphysics \
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
