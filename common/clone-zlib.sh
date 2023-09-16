#!/bin/bash

source ../common/versions.sh

if [[ ! -d zlib-ng ]]; then
  git clone https://github.com/zlib-ng/zlib-ng
fi

if [[ ! -d bzip2 ]]; then
  git clone https://gitlab.com/bzip2/bzip2
fi
  
if [[ ! -d zstd ]]; then
  git clone https://github.com/facebook/zstd
fi

if [[ ! -d brotli ]]; then
  git clone https://github.com/google/brotli
fi

if [[ ! -d xz ]]; then
  git clone https://git.tukaani.org/xz.git
fi

if [[ ! -d snappy ]]; then
  git clone https://github.com/jcelerier/snappy
  (cd snappy ; git checkout ossia)
fi
