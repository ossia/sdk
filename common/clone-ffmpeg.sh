#!/bin/bash

source ../common/versions.sh

FFMPEG_SRC="ffmpeg-$FFMPEG_VERSION"
# Marker inside the tree, not just "does the directory exist". Fetch and patch
# used to sit behind one directory test, so anything that interrupted the script
# between the two (a missing `patch`, a killed job) left an EXTRACTED BUT
# UNPATCHED tree that every later run then skipped -- and the failure surfaced
# far away as "Unknown option --enable-sand". The runners keep their work dir
# between runs, so that state was permanent.
FFMPEG_READY="$FFMPEG_SRC/.ossia-prepared"

if [[ ! -d "$FFMPEG_SRC" ]]; then
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
      && mkdir -p "$FFMPEG_SRC" \
      && tar xzf "ffmpeg-$FFMPEG_VERSION.tar.gz" -C "$FFMPEG_SRC" --strip-components=1 \
      && return 0
    curl -fksSLOJ "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2" \
      && tar xjf "ffmpeg-$FFMPEG_VERSION.tar.bz2"
  }
  fetch_ffmpeg || { echo "clone-ffmpeg: every source failed for $FFMPEG_SRC" >&2; exit 1; }
fi

if [[ ! -f "$FFMPEG_READY" ]]; then
  case "$OSTYPE" in
    darwin*)  echo "Mac OS" ;;
    win*)     echo "Windows" ;;
    msys*)    echo "MSYS / MinGW / Git Bash" ;;
    cygwin*)  echo "Cygwin" ;;
    *)
      echo "Linux or BSD"
     (
      set -e
      # `patch` is preinstalled nearly everywhere; yum only exists on the
      # almalinux build image. Do not make the whole Linux branch depend on a
      # RedHat package manager -- that makes these scripts unrunnable on any
      # other distro (caught on an Arch aarch64 box: "yum: command not found").
      if ! command -v patch >/dev/null 2>&1; then
        command -v yum >/dev/null 2>&1 && yum -y install patch
      fi
      cd "$FFMPEG_SRC"
      patch -p1 < ../../common/patches/ffmpeg/0001-rpi.patch

      sed -i "1i \ #define V4L2_PIX_FMT_P010    v4l2_fourcc('P', '0', '1', '0') /* 24  Y/CbCr 4:2:0 10-bit per component */"  libavcodec/v4l2_req_hevc_vx.c
     )
    ;;
  esac
  # Only now is the tree usable. Written after the patch so an interrupted run
  # is retried rather than silently accepted.
  touch "$FFMPEG_READY"
fi
