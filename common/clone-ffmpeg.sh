#!/bin/bash

source ../common/versions.sh


if [[ ! -d ffmpeg-$FFMPEG_VERSION ]]; then
  # The ossia release is the primary source because the ffmpeg webserver is too
  # unreliable to gate CI on. It only carries the versions we have already
  # mirrored, so fall back to upstream (github first, ffmpeg.org last) -- that
  # keeps a version bump from being blocked on someone uploading the tarball.
  # Mirror the new tarball to the release afterwards to get the fast path back.
  fetch_ffmpeg() {
    curl -fksSLOJ "https://github.com/ossia/sdk/releases/download/sdk36/ffmpeg-$FFMPEG_VERSION.tar.bz2" \
      && tar xjf "ffmpeg-$FFMPEG_VERSION.tar.bz2" && return 0
    echo "clone-ffmpeg: not on the ossia mirror, falling back upstream" >&2
    curl -fksSL -o "ffmpeg-$FFMPEG_VERSION.tar.gz" \
      "https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n$FFMPEG_VERSION.tar.gz" \
      && mkdir -p "ffmpeg-$FFMPEG_VERSION" \
      && tar xzf "ffmpeg-$FFMPEG_VERSION.tar.gz" -C "ffmpeg-$FFMPEG_VERSION" --strip-components=1 \
      && return 0
    curl -fksSLOJ "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2" \
      && tar xjf "ffmpeg-$FFMPEG_VERSION.tar.bz2"
  }
  fetch_ffmpeg

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
      patch -p1 < ../../common/patches/ffmpeg/0001-rpi.patch

      sed -i "1i \ #define V4L2_PIX_FMT_P010    v4l2_fourcc('P', '0', '1', '0') /* 24  Y/CbCr 4:2:0 10-bit per component */"  libavcodec/v4l2_req_hevc_vx.c
     )
    ;;
  esac

fi
