#!/bin/bash -eux
# Note ! you need to install ActivePerl and Python before
source ./common.sh
export PATH=/c/Perl64/bin:$HOMEPATH/AppData/Local/Programs/Python/Python37:$PATH
(
  git clone https://code.qt.io/qt/qt5.git

  cd qt5
  git checkout 5.13
  git submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
)
export MAKE="mingw32-make"
mkdir -p qt5-build-static
(
  cd qt5-build-static
  ../qt5/configure -platform win32-clang-g++ \
                   -release \
                   -opensource \
                   -confirm-license \
                   -nomake examples \
                   -nomake tests \
                   -no-compile-examples \
                   -no-qml-debug \
                   -static \
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
                   -strip \
                   -no-feature-accessibility \
                   -gc-binaries \
                   -opengl desktop \
                   -prefix $INSTALL_PREFIX/qt5-static

  mingw32-make -j$NPROC
  mingw32-make install -j$NPROC
)
