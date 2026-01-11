#!/bin/bash

source ../common/versions.sh

if [[ ! -d ysfx ]]; then
(
  git clone --recursive https://github.com/jcelerier/ysfx
  cd ysfx
  git checkout fae7420f6bf10fbe8cd22da6d1974af755514b45
)
fi
