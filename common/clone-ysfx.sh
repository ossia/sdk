#!/bin/bash

source ../common/versions.sh

if [[ ! -d ysfx ]]; then
(
  git clone --recursive https://github.com/jcelerier/ysfx -b ossia/2026-01
)
fi
