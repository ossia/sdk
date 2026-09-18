#!/bin/bash

source ./common.sh clang
source ../common/clone-openssl.sh

if [[ -f $INSTALL_PREFIX/openssl/.ossia-sdk-openssl-complete ]]; then
  exit 0
fi

OPENSSL_DEBUG_FLAGS=()
if [[ "${SDK_DEBUG:-0}" == 1 ]]; then
  # OpenSSL's typed STACK_OF callbacks intentionally erase their argument
  # types through OPENSSL_sk_*; Clang's function-type sanitizer cannot model
  # that API. Keep every other ASan/UBSan check enabled.
  export CFLAGS="$CFLAGS -fno-sanitize=function"
  OPENSSL_DEBUG_FLAGS+=(-d enable-asan)
fi

cd "openssl-$OPENSSL_VERSION"
CC="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" ./Configure linux-$ARCH \
  -no-shared "${OPENSSL_DEBUG_FLAGS[@]}" --prefix=$INSTALL_PREFIX/openssl
make
make install_sw install_ssldirs
touch "$INSTALL_PREFIX/openssl/.ossia-sdk-openssl-complete"
