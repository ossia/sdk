#!/bin/bash -eux

source ./common.sh

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
if [[ ! -d qt5 ]]; then
git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.15
  git submodule update --init --recursive $(cat "$SDK_COMMON_ROOT/common/qtmodules")
  
  git clone https://github.com/jcelerier/qtshadertools.git

  (
    cd qtbase
    # git fetch "https://codereview.qt-project.org/qt/qtbase" refs/changes/27/285127/1 && git checkout FETCH_HEAD
    sed -i "s/-O2/$CFLAGS/" mkspecs/common/gcc-base.conf 
  )
)
fi

mkdir -p qt5-build-static-debug
(
  cd qt5-build-static-debug
  ../qt5/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -debug -static \
                   -feature-style-windows \
                   -platform win32-clang-g++ \
                   -opengl desktop \
                   -feature-schannel \
                   -prefix $INSTALL_PREFIX/qt5-static-debug
# -openssl-linked OPENSSL_PREFIX="$INSTALL_PREFIX/openssl" \

make -j$NPROC
make install -j$NPROC
)

(
  cd qt5/qtshadertools
  git clean -dffx
  $INSTALL_PREFIX/qt5-static-debug/bin/qmake
  make -j12
  make install -j12
)
