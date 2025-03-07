#!/bin/bash -eu

source ../common/versions.sh

if command -v gsed; then
  SED=gsed
else
  SED=sed
fi

if [[ ! -d SDL2-$SDL_VERSION ]]; then
  wget --no-check-certificate -nv https://www.libsdl.org/release/SDL2-$SDL_VERSION.tar.gz
  tar xzf SDL2-$SDL_VERSION.tar.gz
  $SED -i '/error Nope/d' "SDL2-$SDL_VERSION/src/dynapi/SDL_dynapi.h"
  $SED -i 's/IBUS_FOUND/0/' "SDL2-$SDL_VERSION/CMakeLists.txt"
fi
