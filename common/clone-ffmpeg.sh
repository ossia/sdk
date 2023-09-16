#!/bin/bash

source ../common/versions.sh

if [[ ! -d ffmpeg ]]; then
  wget -nv --no-check-certificate https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2
  tar xaf ffmpeg-$FFMPEG_VERSION.tar.bz2
fi
