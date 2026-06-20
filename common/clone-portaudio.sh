#!/bin/bash

source ../common/versions.sh

if [[ ! -d portaudio ]]; then
(
  git clone $SDK_CLONE_DEPTH https://github.com/portaudio/portaudio
)
fi
