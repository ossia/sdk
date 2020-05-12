#!/bin/bash -eux

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

if [[ ! -d qt5 ]]; then
git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.15
  git submodule update --init --recursive qtbase qtdeclarative qtserialport qtimageformats qtwebsockets
  
  git clone https://code.qt.io/qt-labs/qtshadertools.git
)

# disabled since we can't seem to make custom libc++ not crash...
# echo 'QMAKE_LFLAGS+= -L/opt/score-sdk-osx/llvm/lib -lc++ -lc++abi -Wl,-rpath,/opt/score-sdk-osx/llvm/lib' >> qt5/qtbase/mkspecs/common/clang-mac.conf
gsed -i "s/-O2/$CFLAGS/" qt5/qtbase/mkspecs/common/gcc-base.conf
gsed -i "s/10.13/10.14/" qt5/qtbase/mkspecs/common/macx.conf
#echo "QMAKE_CFLAGS+=$CFLAGS" >> qt5/qtbase/mkspecs/common/clang-mac.conf
#echo "QMAKE_CXXFLAGS+=$CXXFLAGS" >> qt5/qtbase/mkspecs/common/clang-mac.conf
fi


mkdir -p qt5-build-static
(
  exit 0
  cd qt5-build-static
  ../qt5/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -c++std c++17 \
                   -static \
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
                   -no-cups \
                   -no-iconv \
                   -no-tslib \
                   -no-icu \
                   -no-system-proxies \
                   -prefix $INSTALL_PREFIX/qt5-static

  make -j$NPROC
  make install -j$NPROC
)
(
  cd qt5
  cd qtshadertools
  git clean -dffx
  $INSTALL_PREFIX/qt5-static/bin/qmake 
  make -j$NPROC
  make install -j$NPROC
)

