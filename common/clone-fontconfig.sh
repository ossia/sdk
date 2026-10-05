#!/bin/bash

source ../common/versions.sh

_fc_fetch() {  # dir tar-decompression-flag url
  [[ -d "$1" ]] && return 0
  rm -rf "$1.tmp"
  mkdir -p "$1.tmp"
  curl -fksSL "$3" | tar "x$2" -C "$1.tmp" --strip-components=1
  mv "$1.tmp" "$1"
}

_fc_fetch "expat-$EXPAT_VERSION" J \
  "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION//./_}/expat-$EXPAT_VERSION.tar.xz"
_fc_fetch "fontconfig-$FONTCONFIG_VERSION" J \
  "https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/$FONTCONFIG_VERSION/fontconfig-$FONTCONFIG_VERSION.tar.xz"
# meson is pure python and runs from its source tree; nothing is installed.
_fc_fetch "meson-$FONTCONFIG_MESON_VERSION" z \
  "https://github.com/mesonbuild/meson/releases/download/$FONTCONFIG_MESON_VERSION/meson-$FONTCONFIG_MESON_VERSION.tar.gz"
