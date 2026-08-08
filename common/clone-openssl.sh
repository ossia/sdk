#!/bin/bash

source ../common/versions.sh

# Guard on the extracted TREE, not the tarball. The self-hosted runners keep
# their work dir between runs, so a source tree removed by hand (or by a failed
# build) while the tarball survived would never be re-extracted, and the caller
# would then die on `cd openssl-$OPENSSL_VERSION: No such file or directory`.
if [[ ! -d openssl-$OPENSSL_VERSION ]]; then
  if [[ ! -f openssl-$OPENSSL_VERSION.tar.gz ]]; then
    curl -ksSLOJ https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz
  fi
  # -z, not -a: bsdtar rejects -a in extract mode outright on macOS 15
  # ("Option -a is not permitted in mode -x"). macOS 26's bsdtar only warns,
  # so this passed on the arm64 runner and failed on the Intel one. The asset
  # is always .tar.gz, so name the decompressor.
  tar xzf openssl-$OPENSSL_VERSION.tar.gz
fi
