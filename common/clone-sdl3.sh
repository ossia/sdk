#!/bin/bash -eu

source ../common/versions.sh

if command -v gsed; then
  SED=gsed
else
  SED=sed
fi

if [[ ! -d SDL3-$SDL3_VERSION ]]; then
  curl -ksSLOJ "https://github.com/libsdl-org/SDL/releases/download/release-$SDL3_VERSION/SDL3-$SDL3_VERSION.tar.gz"
  tar xzf SDL3-$SDL3_VERSION.tar.gz
  $SED -i '/error Nope/d' "SDL3-$SDL3_VERSION/src/dynapi/SDL_dynapi.h"
fi
