#!/bin/bash

source ../common/versions.sh

if [[ ! -d SDL2-$SDL_VERSION ]]; then
  wget --no-check-certificate -nv https://www.libsdl.org/release/SDL2-$SDL_VERSION.tar.gz
  tar xaf SDL2-$SDL_VERSION.tar.gz
  sed -i '/error Nope/d' SDL2-$SDL_VERSION/src/dynapi/SDL_dynapi.h
fi