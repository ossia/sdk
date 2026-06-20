#!/bin/bash

source ../common/versions.sh

if [[ ! -d ysfx ]]; then
(
  git clone --recursive $SDK_CLONE_DEPTH $SDK_SHALLOW_SUBMODULES https://github.com/jcelerier/ysfx -b ossia/2026-01
)
fi
