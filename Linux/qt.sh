#!/bin/bash -eux

source ./common.sh

yum install glibc-devel devtoolset-7-gcc devtoolset-7-make libxcb-devel xcb-util xcb-util-devel which mesa-libGL-devel
git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.12.0
  git submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
  
  sed -i 's/fuse-ld=gold/fuse-ld=lld/g' \
    qtbase/mkspecs/common/gcc-base-unix.conf \
    qtbase/mkspecs/features/qt_configure.prf \
    qtbase/configure.json   
)

mkdir qt5-build-dynamic
(
  cd qt5-build-dynamic
  
  
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
                   -qt-xcb \
                   -qt-xkbcommon-x11 \
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
                   OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a" \
                   -I$INSTALL_PREFIX/openssl/include \
                   -no-dbus \
                   -no-system-proxies \
                   -platform linux-clang-libc++ \
                   -prefix $INSTALL_PREFIX/qt5-dynamic

  make -j$NPROC
  make install -j$NPROC
)
