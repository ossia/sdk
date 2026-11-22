#!/bin/bash

source ../common/versions.sh

# Keep both source and build directories keyed by release: old SDK clones and
# local development branches are not ours to reset when a pin changes.
_compression_clone() {  # directory tag url
  local dir=$1 tag=$2 url=$3
  if [[ ! -e "$dir" ]]; then
    git clone $SDK_CLONE_DEPTH --branch "$tag" "$url" "$dir" || return 1
  fi
  # Fail closed if a cached directory was repurposed or locally edited.
  [[ -d "$dir/.git" ]] &&
    git -C "$dir" diff --quiet "refs/tags/$tag" -- &&
    [[ "$(git -C "$dir" rev-parse HEAD)" == "$(git -C "$dir" rev-parse "refs/tags/$tag^{commit}")" ]] ||
    { echo "compression: $dir is not a clean checkout of $tag; move it aside" >&2; return 1; }
}

ZLIB_NG_SRC="zlib-ng-$ZLIB_NG_VERSION"
ZSTD_SRC="zstd-$ZSTD_VERSION"
BROTLI_SRC="brotli-$BROTLI_VERSION"
XZ_SRC="xz-$XZ_VERSION"
SNAPPY_SRC="snappy-$SNAPPY_VERSION"

_compression_clone "$ZLIB_NG_SRC" "$ZLIB_NG_VERSION" https://github.com/zlib-ng/zlib-ng
_compression_clone "$BZIP2_VERSION" "$BZIP2_VERSION" https://sourceware.org/git/bzip2.git
_compression_clone "$ZSTD_SRC" "$ZSTD_VERSION" https://github.com/meta/zstd
_compression_clone "$BROTLI_SRC" "$BROTLI_VERSION" https://github.com/google/brotli
_compression_clone "$XZ_SRC" "$XZ_VERSION" https://github.com/tukaani-project/xz
_compression_clone "$SNAPPY_SRC" "$SNAPPY_VERSION" https://github.com/google/snappy
