#!/bin/bash -e

source ./common.sh clang
source ../common/clone-openssl.sh

if openssl_is_current "$INSTALL_PREFIX/openssl/bin/openssl"; then
  exit 0
fi

cd "openssl-$OPENSSL_VERSION"
CC="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" ./Configure linux-$ARCH -no-shared --prefix=$INSTALL_PREFIX/openssl
make
make install_sw install_ssldirs
