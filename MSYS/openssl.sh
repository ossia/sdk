#!/bin/bash

source ./common.sh
source ../common/clone-openssl.sh

cd "openssl-OpenSSL_$OPENSSL_VERSION"
./Configure mingw64 -no-shared --prefix=$INSTALL_PREFIX/openssl
make
