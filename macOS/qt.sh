#!/bin/bash -eux

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

if [[ ! -d qt5 ]]; then
git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.15
  git submodule update --init --recursive $(cat "$SDK_COMMON_ROOT/common/qtmodules")
  
  git clone https://github.com/jcelerier/qtshadertools.git
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
  cd qt5-build-static
  ../qt5/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -system-zlib \
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

