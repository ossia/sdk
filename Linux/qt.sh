#!/bin/bash -eux
export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

if [[ ! -d qt5 ]]; then
  git clone https://code.qt.io/qt/qt5.git
  (
    cd qt5
    $GIT checkout 5.15
    git submodule update --init --recursive  $(cat "$SDK_COMMON_ROOT/common/qtmodules")
    (
      cd qtbase
      $GIT checkout 5.15
      # $GIT cherry-pick a486c71
      sed -i "s/-O2/$CFLAGS/" mkspecs/common/gcc-base.conf
    )
  )
fi
mkdir -p qt5-build-static
(
  cd qt5-build-static
  
  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt5/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -system-zlib \
                   -openssl-linked \
                   -I$INSTALL_PREFIX/openssl/include \
                   -platform linux-clang-libc++ \
                   -prefix $INSTALL_PREFIX/qt5-static

  make -j$NPROC
  make install -j$NPROC
)

(
  cd qt5
  $GIT clone https://code.qt.io/qt-labs/qtshadertools.git
  cd qtshadertools
  sed -i '311d' src/3rdparty/glslang/glslang/Include/PoolAlloc.h
  sed -i '244d' src/3rdparty/glslang/glslang/Include/PoolAlloc.h
  $INSTALL_PREFIX/qt5-static/bin/qmake 
  make -j$NPROC
  make install -j$NPROC
)
exit 0

mkdir qt5-build-dynamic
(
  cd qt5-build-dynamic
  
  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt5/configure -release \
                   -opensource \
                   -confirm-license \
                   -nomake examples \
                   -nomake tests \
                   -no-compile-examples \
                   -no-qml-debug \
                   -qt-zlib \
                   -no-mtdev \
                   -no-journald \
                   -no-syslog \
                   -no-gif \
                   -qt-libpng \
                   -qt-libjpeg \
                   -qt-zlib \
                   -qt-freetype \
                   -qt-harfbuzz \
                   -qt-pcre \
                   -no-glib \
                   -no-cups \
                   -no-iconv \
                   -no-tslib \
                   -no-icu \
                   -no-pch \
                   -no-kms \
                   -no-gbm \
                   -no-directfb \
                   -no-eglfs \
                   -no-mirclient \
                   -openssl-linked \
                   -I$INSTALL_PREFIX/openssl/include \
                   -no-dbus \
                   -no-system-proxies \
                   -platform linux-clang-libc++ \
                   -prefix $INSTALL_PREFIX/qt5-dynamic

  make -j$NPROC
  make install -j$NPROC
)

                  # -qt-xcb \
