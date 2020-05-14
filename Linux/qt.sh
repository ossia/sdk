#!/bin/bash -eux
export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

mkdir -p qt5-build-static
(
  cd qt5-build-static
  
  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt5/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -system-zlib \
                   -openssl-linked \
                   -I$INSTALL_PREFIX/openssl/include \
                   -platform linux-clang-libc++ \
                   -prefix $INSTALL_PREFIX/qt5-static

  make -j$NPROC
  make install -j$NPROC
)

(
  cd qt5
  $GIT clone https://code.qt.io/qt-labs/qtshadertools.git
  cd qtshadertools
  sed -i '311d' src/3rdparty/glslang/glslang/Include/PoolAlloc.h
  sed -i '244d' src/3rdparty/glslang/glslang/Include/PoolAlloc.h
  $INSTALL_PREFIX/qt5-static/bin/qmake 
  make -j$NPROC
  make install -j$NPROC
)