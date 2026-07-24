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

# HarfBuzz features the SDK does not use -- Qt links libharfbuzz only for text
# shaping. The ossia-2026-05 bump (HarfBuzz 12.x) turns the new raster + gpu
# glyph-rasterization libraries on by default, and they auto-detect libpng,
# cairo and chafa from whatever the runner happens to ship. On the macOS x86_64
# cross build that pulled in an arm64 homebrew libpng and broke the link with a
# wall of undefined _png_* symbols. None of it is needed; disabling keeps the
# static lib self-contained and byte-for-byte reproducible across runners.
HB_SHAPING_ONLY=(
  -Dcairo=disabled
  -Dchafa=disabled
  -Dpng=disabled
  -Draster=disabled
  -Dgpu=disabled
  -Dgpu_demo=disabled
  -Dutilities=disabled
)
