#!/bin/bash

source ../common/versions.sh

if [[ ! -d zlib-ng ]]; then
  git clone $SDK_CLONE_DEPTH https://github.com/zlib-ng/zlib-ng
fi

if [[ ! -d bzip2 ]]; then
  git clone $SDK_CLONE_DEPTH https://gitlab.com/bzip2/bzip2
fi
  
if [[ ! -d zstd ]]; then
  git clone $SDK_CLONE_DEPTH https://github.com/facebook/zstd
fi

if [[ ! -d brotli ]]; then
  git clone $SDK_CLONE_DEPTH https://github.com/google/brotli
fi

if [[ ! -d xz ]]; then
  git clone $SDK_CLONE_DEPTH https://github.com/tukaani-project/xz
fi

if [[ ! -d snappy ]]; then
  git clone $SDK_CLONE_DEPTH ${SDK_CLONE_DEPTH:+-b ossia-2025-03-31} https://github.com/jcelerier/snappy
  (cd snappy ; git checkout ossia-2025-03-31)
fi
