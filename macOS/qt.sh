#!/bin/bash -eux

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

if [[ ! -d qt5 ]]; then
git clone https://invent.kde.org/qt/qt/qt5

(
  cd qt5
  git checkout kde/5.15
  git submodule update --init --recursive $(cat "$SDK_COMMON_ROOT/common/qtmodules")

  (
    cd qtbase
    git remote add jcelerier https://github.com/jcelerier/qtbase
    git fetch jcelerier
    git checkout jcelerier/kde/5.15
  )
  
  git clone https://github.com/jcelerier/qtshadertools.git
)

# disabled since we can't seem to make custom libc++ not crash...
# echo 'QMAKE_LFLAGS+= -L/opt/score-sdk-osx/llvm/lib -lc++ -lc++abi -Wl,-rpath,/opt/score-sdk-osx/llvm/lib' >> qt5/qtbase/mkspecs/common/clang-mac.conf

(
  cd qt5/qtbase/mkspecs/common
  gsed -i "s/-O2/$CFLAGS/" gcc-base.conf
  gsed -i 's/-fvisibility=hidden/-fvisibility=default/g' gcc-base.conf
  gsed -i 's/-fvisibility-inlines-hidden/ /g' gcc-base.conf

  # gsed -i "s/10.13/10.14/" macx.conf
  #echo "QMAKE_CFLAGS+=$CFLAGS" >> clang-mac.conf
  #echo "QMAKE_CXXFLAGS+=$CXXFLAGS" >> clang-mac.conf
)
fi


mkdir -p qt5-build-static
(
  cd qt5-build-static
  ../qt5/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -system-zlib -no-feature-zstd \
                   -system-freetype \
                   FREETYPE_INCDIR=$INSTALL_PREFIX/freetype/include/freetype2 \
                   FREETYPE_LIBS=$INSTALL_PREFIX/freetype/lib/libfreetype.a \
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

