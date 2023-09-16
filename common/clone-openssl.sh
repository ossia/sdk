#!/bin/bash

source ../common/versions.sh

if [[ ! -f OpenSSL_$OPENSSL_VERSION.tar.gz ]]; then
  wget -nv https://github.com/openssl/openssl/archive/OpenSSL_$OPENSSL_VERSION.tar.gz
  tar xaf OpenSSL_$OPENSSL_VERSION.tar.gz
fi
