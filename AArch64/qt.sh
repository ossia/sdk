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
  unset PKG_CONFIG_LIBDIR
  unset PKG_CONFIG_PATH
  export PATH=$ORIGPATH

  CC=$CROSS_COMPILER_LOCATION/bin/clang 
  CXX="$CROSS_COMPILER_LOCATION/bin/clang++ -stdlib=libc++ "
  cmake -S qt -B qt6-build-host \
     -GNinja \
     -DFEATURE_eglfs=OFF \
     -DQT_BUILD_EXAMPLES=OFF \
     -DQT_BUILD_TESTS=OFF \
     -DBUILD_SHARED_LIBS=ON \
     -DCMAKE_BUILD_TYPE=Release \
     -DQT_DISABLE_DEPRECATED_UP_TO=0x060600 \
     -DCMAKE_INSTALL_PREFIX=$SDK_INSTALL_ROOT/qt6-host \
     -DBUILD_qtwayland=ON \
     -DFEATURE_wayland_client=OFF \
     -DFEATURE_wayland_server=OFF

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
      -DQT_BUILD_EXAMPLES=OFF 
      -DQT_BUILD_TESTS=OFF 
      -DFEATURE_gtk3=OFF
      -DFEATURE_glib=OFF
      
      # we're not there yet: error: use of undeclared identifier 'wl_proxy_marshal_flags'
      -DBUILD_qtwayland=OFF
      -DFEATURE_wayland_client=OFF
      -DFEATURE_wayland_server=OFF

      -DQT_DISABLE_DEPRECATED_UP_TO=0x060600
      -DQT_HOST_PATH=$SDK_INSTALL_ROOT/qt6-host
      -DZLIB_ROOT="$INSTALL_PREFIX_CMAKE/sysroot"
      -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX_CMAKE;$INSTALL_PREFIX_CMAKE/sysroot;$INSTALL_PREFIX_CMAKE/sysroot/lib/cmake"
      # Fixme custom ft & harfbuzz                
  )
  
  ../qt/configure $(cat "$SDK_ROOT/../../common/qtfeatures") "${QT_OPTIONS[@]}" "${CMAKE_COMMON_FLAGS[@]}"

  cmake --build . --parallel
  cmake --build . --target install/strip
)
