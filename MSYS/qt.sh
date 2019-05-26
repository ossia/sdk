#!/bin/bash -eux

source ./common.sh
export PATH=/c/Perl64/bin:$PATH

git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.12
  git submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
)

mkdir -p qt5-build-dynamic
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
                   -no-gif \
                   -qt-libpng \
                   -qt-libjpeg \
                   -qt-freetype \
                   -qt-harfbuzz \
                   -qt-pcre \
                   -no-iconv \
                   -no-tslib \
                   -no-icu \
                   -no-pch \
                   -opengl desktop \
                   -platform win32-clang-g++ \
                   -prefix $INSTALL_PREFIX/qt5-dynamic

  make -j$NPROC
  make install -j$NPROC
)
