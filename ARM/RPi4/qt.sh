#!/bin/bash -eux
source ./common.sh

mkdir -p qt5-build-static
(
  cd qt5-build-static

  export SYSROOT_LOCATION=$SDK_INSTALL_ROOT/pi/sysroot

  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/lib
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/lib:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/libc/usr/lib:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/libc/lib:$LD_LIBRARY_PATH

  export LDFLAGS="-L$CROSS_COMPILER_LOCATION/lib/ -L$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/lib/"

  ../qt5/configure $(cat "$SDK_ROOT/common/qtfeatures") \
                   -release -opengl es2 -eglfs \
                   -device $QT_CROSS_DEVICE \
                   -pkg-config \
                   -device-option CROSS_COMPILE=$CCPREFIX \
                   -sysroot $SYSROOT_LOCATION \
                   -prefix $INSTALL_PREFIX/qt5-static \
                   -extprefix $INSTALL_PREFIX/qt5-static \
                   -static \
                   -system-zlib \
                   -no-feature-wayland-server \
                   -no-feature-zstd \
                   -v -recheck \
                   -L$CROSS_COMPILER_LOCATION/lib/ -L$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/lib/ \
                   -L$SYSROOT_LOCATION/usr/lib/$DEBIAN_MULTIARCH_FOLDER -I$SYSROOT_LOCATION/usr/include/$DEBIAN_MULTIARCH_FOLDER

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
