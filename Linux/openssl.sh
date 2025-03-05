#!/bin/bash

source ./common.sh clang
source ../common/clone-openssl.sh

if [[ -f /opt/ossia-sdk/openssl/lib64/libssl.a ]]; then
  exit 0
fi

cd "openssl-$OPENSSL_VERSION"
./Configure linux-x86_64-clang -no-shared --prefix=$INSTALL_PREFIX/openssl
make
make install_sw install_ssldirs
