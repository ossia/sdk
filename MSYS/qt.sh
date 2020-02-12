#!/bin/bash -eux

source ./common.sh

if [[ ! -d qt5 ]]; then
git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.15
  git submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
  
  git clone https://code.qt.io/qt-labs/qtshadertools.git
  
  cd qtbase
  # git fetch "https://codereview.qt-project.org/qt/qtbase" refs/changes/27/285127/1 && git checkout FETCH_HEAD
  sed -i "s/-O2/$CFLAGS/" mkspecs/common/gcc-base.conf 
  
  
)
fi

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
                   -no-gif \
                   -qt-libpng \
                   -qt-libjpeg \
                   -qt-zlib \
                   -qt-freetype \
                   -qt-harfbuzz \
                   -qt-pcre \
                   -no-iconv \
                   -no-tslib \
                   -no-icu \
                   -no-pch \
                   -platform win32-clang-g++ \
                   -opengl desktop \
                   -prefix $INSTALL_PREFIX/qt5-dynamic

make -j$NPROC
make install -j$NPROC
)

(
  cd qt5/qtshadertools
  $INSTALL_PREFIX/qt5-dynamic/bin/qmake
  make -j12
  make install -j12
)
