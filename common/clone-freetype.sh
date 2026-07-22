#!/bin/bash

source ../common/versions.sh

if [[ ! -d freetype ]]; then
(
  (
    # NB: keep the -b branch and the checkout below in sync. In CI SDK_CLONE_DEPTH
    # is set, which makes this a shallow single-branch clone -- so a checkout of
    # any *other* branch cannot work, it was never fetched.
    git clone $SDK_CLONE_DEPTH ${SDK_CLONE_DEPTH:+-b ossia-2026-05} https://github.com/jcelerier/freetype
    cd freetype
    git checkout ossia-2026-05
    git remote add upstream https://github.com/freetype/freetype
  )

  (
    git clone $SDK_CLONE_DEPTH ${SDK_CLONE_DEPTH:+-b ossia-2026-05} https://github.com/jcelerier/harfbuzz
    cd harfbuzz
    git checkout ossia-2026-05
    git remote add upstream https://github.com/harfbuzz/harfbuzz
  )
  
)
fi
