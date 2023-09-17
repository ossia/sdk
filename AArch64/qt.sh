#!/bin/bash -eux
export ORIGPATH="$PATH"
source ./common.sh clang
source "$SDK_COMMON_ROOT/common/clone-qt.sh"

if [[ ! -d "$SDK_INSTALL_ROOT/qt6-host" ]]; then
(
  unset CC
  unset CXX
  unset CFLAGS
  unset CXXFLAGS
  export PATH=$ORIGPATH

  cmake -S qt6 -B qt6-build-host \
     -GNinja \
     -DFEATURE_eglfs=0 \
     -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=$SDK_INSTALL_ROOT/qt6-host

  cmake --build qt6-build-host
  cmake --build qt6-build-host --target install/strip
)
fi

export PKG_CONFIG_LIBDIR=/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/share/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/aarch64-rpi3-linux-gnu/pkgconfig
export PKG_CONFIG_PATH=/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/share/pkgconfig
(
  mkdir -p qt6-build-static
  cd  qt6-build-static

  QT_OPTIONS=(
      -release
      -opengl es2
      -eglfs
      -kms
      -xcb
      -vulkan
      -system-freetype -system-harfbuzz
      -skip qtimageformats
      -pkg-config
      -static
      -prefix $INSTALL_PREFIX/qt6-static
      -extprefix $INSTALL_PREFIX/qt6-static
      --
      -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN
      -DQT_HOST_PATH=$SDK_INSTALL_ROOT/qt6-host
  )
  
  ../qt6/configure $(cat "$SDK_ROOT/../../common/qtfeatures") "${QT_OPTIONS[@]}"

  cmake --build . --parallel
  cmake --build . --target install/strip
)
