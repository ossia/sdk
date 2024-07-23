#!/bin/bash

source ../common/versions.sh

TARGET=${1:-}

if [[ "$TARGET" = "raspi" ]]; then
  if [[ ! -d ffmpeg ]]; then
    git clone -b dev/5.1.2/rpi_import_1 https://github.com/jc-kynesim/rpi-ffmpeg ffmpeg
  fi
else
  if [[ ! -d ffmpeg ]]; then
    wget -nv --no-check-certificate https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2
    tar xaf ffmpeg-$FFMPEG_VERSION.tar.bz2
  fi
fi

