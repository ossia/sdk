#!/bin/bash -eux
source ./common.sh

mkdir -p qt5-build-static
(
  cd qt5-build-static
  
  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt5/configure $(cat "$SDK_ROOT/common/qtfeatures") \
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
  $GIT clone https://github.com/jcelerier/qtshadertools.git
  cd qtshadertools
  $INSTALL_PREFIX/qt5-static/bin/qmake 
  make -j$NPROC
  make install -j$NPROC
)
