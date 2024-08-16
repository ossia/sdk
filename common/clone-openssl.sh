#!/bin/bash

source ../common/versions.sh

if [[ ! -f openssl-$OPENSSL_VERSION.tar.gz ]]; then
  wget -nv https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz
  tar xaf openssl-$OPENSSL_VERSION.tar.gz
fi
