#!/bin/bash

source ./common.sh clang
source ../common/clone-openssl.sh

if [[ -f $INSTALL_PREFIX/openssl/bin/openssl ]]; then
  exit 0
fi

cd "openssl-$OPENSSL_VERSION"
./Configure linux-$ARCH -no-shared --prefix=$INSTALL_PREFIX/openssl
make
make install_sw install_ssldirs
