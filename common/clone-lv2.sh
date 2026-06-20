#!/bin/bash

source ../common/versions.sh

if [[ ! -d lv2kit ]]; then
  git clone --recursive -j12 $SDK_CLONE_DEPTH $SDK_SHALLOW_SUBMODULES https://github.com/lv2/lv2kit
fi