#!/bin/bash

source ./common.sh

OPENSSL_VERSION="1_1_0j"

wget -nv https://github.com/openssl/openssl/archive/OpenSSL_$OPENSSL_VERSION.tar.gz 
tar xaf OpenSSL_$OPENSSL_VERSION.tar.gz

cd "openssl-OpenSSL_$OPENSSL_VERSION"
./Configure linux-x86_64-clang -no-shared --prefix=$INSTALL_PREFIX/openssl
make
make install
