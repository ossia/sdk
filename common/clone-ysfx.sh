#!/bin/bash

source ../common/versions.sh

if [[ ! -d ysfx ]]; then
(
  git clone --recursive https://github.com/jpcima/ysfx
)
fi
