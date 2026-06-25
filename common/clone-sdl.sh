#!/bin/bash -eu

source ../common/versions.sh

if command -v gsed; then
  SED=gsed
else
  SED=sed
fi

# SDL3: tarballs moved to the GitHub releases (libsdl.org/release/ is SDL2 only).
if [[ ! -d SDL3-$SDL_VERSION ]]; then
  curl -ksSLOJ "https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL3-$SDL_VERSION.tar.gz"
  tar xzf SDL3-$SDL_VERSION.tar.gz
  # Allow forcing SDL_DYNAMIC_API=0 (fully static, no dynapi indirection).
  $SED -i '/error Nope/d' "SDL3-$SDL_VERSION/src/dynapi/SDL_dynapi.h" || true
fi
