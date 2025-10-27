#!/bin/bash

source ../common/versions.sh


if [[ ! -d ffmpeg-$FFMPEG_VERSION ]]; then
  # Here as the ffmpeg webserver is too unreliable
  curl -ksSLOJ  https://github.com/ossia/sdk/releases/download/sdk33/ffmpeg-$FFMPEG_VERSION.tar.bz2

  tar xjf ffmpeg-$FFMPEG_VERSION.tar.bz2

  case "$OSTYPE" in
    darwin*)  echo "Mac OS" ;; 
    win*)     echo "Windows" ;;
    msys*)    echo "MSYS / MinGW / Git Bash" ;;
    cygwin*)  echo "Cygwin" ;;
    *)        
      echo "Linux or BSD"
     ( 
      yum -y install patch
      cd ffmpeg-$FFMPEG_VERSION
      curl -ksSLOJ https://raw.githubusercontent.com/HiassofT/LibreELEC.tv/refs/heads/le13-ffmpeg-8.0/packages/multimedia/ffmpeg/patches/rpi/ffmpeg-001-rpi.patch
      ls 
      patch -p1 < ffmpeg-001-rpi.patch

      sed -i "1i \ #define V4L2_PIX_FMT_P010    v4l2_fourcc('P', '0', '1', '0') /* 24  Y/CbCr 4:2:0 10-bit per component */"  libavcodec/v4l2_req_hevc_vx.c
     )
    ;;
  esac

fi
