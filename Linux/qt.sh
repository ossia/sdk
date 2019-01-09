#!/bin/bash -eux

source ./common.sh
$GIT clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  $GIT checkout 5.12
  $GIT submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
  
  sed -i 's/fuse-ld=gold/fuse-ld=lld/g' \
    qtbase/mkspecs/common/gcc-base-unix.conf \
    qtbase/mkspecs/features/qt_configure.prf \
    qtbase/configure.json   
)

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
                   -qt-xcb \
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

exit 0
mkdir qt5-build-static
(
  cd qt5-build-static
  
  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt5/configure -release \
                   -opensource \
                   -static \
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
                   -prefix $INSTALL_PREFIX/qt5-static

  make -j$NPROC
  make install -j$NPROC
)
