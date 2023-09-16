#!/bin/bash

source ../common/versions.sh

if [[ ! -d portaudio ]]; then
(
  git clone https://github.com/portaudio/portaudio
)
fi
