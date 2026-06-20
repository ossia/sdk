#!/bin/bash

source ../common/versions.sh

if [[ ! -d jack2 ]]; then
  git clone $SDK_CLONE_DEPTH https://github.com/jackaudio/jack2
fi