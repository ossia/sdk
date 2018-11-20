#!/bin/bash
OPENSSL_VERSION="1_1_0j"

wget -nv https://github.com/openssl/openssl/archive/OpenSSL_$OPENSSL_VERSION.tar.gz 
gtar xaf OpenSSL_$OPENSSL_VERSION.tar.gz

cd "openssl-OpenSSL_$OPENSSL_VERSION"
./Configure darwin64-x86_64-cc -no-shared --prefix=/opt/score-sdk/openssl
make

