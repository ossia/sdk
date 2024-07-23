#!/bin/bash

source ../common/versions.sh

if [[ ! -d freetype ]]; then
(
  (
    git clone https://github.com/jcelerier/freetype
    cd freetype
    git checkout ossia-2024-07
    git remote add upstream https://github.com/freetype/freetype
  )
  
  (
    git clone https://github.com/jcelerier/harfbuzz
    cd harfbuzz
    git checkout ossia
  )
  
)
fi
