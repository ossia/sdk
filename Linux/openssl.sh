#!/bin/bash

source ./common.sh
source ../common/clone-openssl.sh

cd "openssl-$OPENSSL_VERSION"
./Configure linux-x86_64-clang -no-shared --prefix=$INSTALL_PREFIX/openssl
make
make install_sw install_ssldirs
