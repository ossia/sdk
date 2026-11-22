#!/bin/bash

source ../common/versions.sh

# Use separate, versioned source trees: never switch or patch an existing
# developer checkout in freetype/ or harfbuzz/. Include the SDK patch in the
# FreeType cache key so editing it also gets a freshly prepared tree.
ft_patch=../common/patches/freetype/ossia.patch
ft_patch_id=$(git hash-object "$ft_patch")
FREETYPE_SRC="freetype-$FREETYPE_VERSION-${ft_patch_id:0:12}"
HARFBUZZ_SRC="harfbuzz-$HARFBUZZ_VERSION"

_font_clone() ( # destination tag upstream [patch]
  [[ -d "$1" ]] && return 0
  local tmp
  tmp=$(mktemp -d "$1.XXXXXX")
  trap 'rm -rf "$tmp"' EXIT
  git clone $SDK_CLONE_DEPTH --branch "$2" "$3" "$tmp"
  if [[ -n "${4:-}" ]]; then
    git -C "$tmp" apply < "$4"
  fi
  mv "$tmp" "$1"
)

# The former FreeType fork enabled subpixel rendering, long PCF family names
# and extra validators, hid bundled zlib symbols, and avoided pkg-config host
# hints for Brotli/HarfBuzz. Carry those changes on the upstream release.
_font_clone "$FREETYPE_SRC" "VER-${FREETYPE_VERSION//./-}" https://github.com/freetype/freetype "$ft_patch"
_font_clone "$HARFBUZZ_SRC" "$HARFBUZZ_VERSION" https://github.com/harfbuzz/harfbuzz

# Qt needs shaping, not the rendering libraries. Keep their optional host
# dependencies (e.g. Homebrew's arm64 libpng on x86_64 builds) out of the SDK.
HB_SHAPING_ONLY=(
  -Dcairo=disabled
  -Dchafa=disabled
  -Dpng=disabled
  -Dzlib=disabled
  -Draster=disabled
  -Dvector=disabled
  -Dgpu=disabled
  -Dgpu_demo=disabled
  -Dutilities=disabled
)
