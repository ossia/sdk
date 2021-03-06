#!/bin/bash -eux
source ./common.sh

mkdir -p qt5-build-static
(
  cd qt5-build-static

  export CROSS_COMPILER_LOCATION=$SDK_INSTALL_ROOT/cross-pi-gcc-10.2.0-2
  export SYSROOT_LOCATION=$SDK_INSTALL_ROOT/pi/sysroot

  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/lib
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/arm-linux-gnueabihf/lib:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/arm-linux-gnueabihf/libc/usr/lib:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/arm-linux-gnueabihf/libc/lib:$LD_LIBRARY_PATH

  export LDFLAGS="-L$CROSS_COMPILER_LOCATION/lib/ -L$CROSS_COMPILER_LOCATION/arm-linux-gnueabihf/lib/"
  export CROSS_PREFIX=$(echo $CROSS_COMPILER_LOCATION)/bin/arm-linux-gnueabihf-

  ../qt5/configure $(cat "$SDK_ROOT/common/qtfeatures") \
                   -release -opengl es2 -eglfs \
                   -device linux-rasp-pi4-v3d-g++ \
                   -pkg-config \
                   -device-option CROSS_COMPILE=$CROSS_PREFIX \
                   -sysroot $SYSROOT_LOCATION \
                   -prefix $INSTALL_PREFIX/qt5-static \
                   -extprefix $INSTALL_PREFIX/qt5-static \
                   -static \
                   -system-zlib \
                   -no-feature-wayland-server \
                   -v -recheck \
                   -L$CROSS_COMPILER_LOCATION/lib/ -L$CROSS_COMPILER_LOCATION/arm-linux-gnueabihf/lib/ \
                   -L$SYSROOT_LOCATION/usr/lib/arm-linux-gnueabihf -I$SYSROOT_LOCATION/usr/include/arm-linux-gnueabihf

  make -j$NPROC
  make install -j$NPROC
)

(
  cd qt5
  if [[ ! -d qtshadertools ]]; then
    git clone https://github.com/jcelerier/qtshadertools.git
  fi
  cd qtshadertools
  git clean -dffx

  $INSTALL_PREFIX/qt5-static/bin/qmake

  make -j$NPROC
  make install -j$NPROC
)
