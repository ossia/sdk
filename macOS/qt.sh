#!/bin/bash -eux

source ./common.sh

if [[ ! -d qt5 ]]; then
git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.14
  git submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
)

# disabled since we can't seem to make custom libc++ not crash...
# echo 'QMAKE_LFLAGS+= -L/opt/score-sdk-osx/llvm/lib -lc++ -lc++abi -Wl,-rpath,/opt/score-sdk-osx/llvm/lib' >> qt5/qtbase/mkspecs/common/clang-mac.conf
gsed -i "s/-O2/$CFLAGS/" qt5/qtbase/mkspecs/common/gcc-base.conf
gsed -i "s/10.13/10.14/" qt5/qtbase/mkspecs/common/macx.conf
#echo "QMAKE_CFLAGS+=$CFLAGS" >> qt5/qtbase/mkspecs/common/clang-mac.conf
#echo "QMAKE_CXXFLAGS+=$CXXFLAGS" >> qt5/qtbase/mkspecs/common/clang-mac.conf
fi


mkdir -p qt5-build-dynamic
(
  cd qt5-build-dynamic
  ../qt5/configure -release \
                   -ltcg \
                   -opensource \
                   -confirm-license \
                   -c++std c++17 \
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
                   -no-cups \
                   -no-iconv \
                   -no-tslib \
                   -no-icu \
                   -no-pch \
                   -no-system-proxies \
                   -prefix $INSTALL_PREFIX/qt5-dynamic

  make -j$NPROC
  make install -j$NPROC
)
