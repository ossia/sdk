#!/usr/bin/env bash
# Guard that the media build does NOT change or remove anything the CORE build
# put in an immutable core directory -- that would mean the shipped SDK depends
# on a side effect that vanishes on the next core rebuild.
# Usage: sysroot-guard.sh <dir> <snapshot_file> <snapshot|verify>
#
# ADDING files is allowed. It used to be an error too, but the media stage now
# legitimately installs into $INSTALL_PREFIX/sysroot on Linux and MSYS: that is
# where media-deps.sh puts the codecs, SRT and the hwaccel headers, and where
# ffmpeg (and later gstreamer) look for them. Those additions are re-created by
# every media build from pinned sources, so they are reproducible and cannot go
# stale against a cached core -- which is the failure mode this guard is for.
#
# What must still never happen is the media stage OVERWRITING or DELETING a core
# artifact: a media build that quietly replaced the core's libz.a or freetype
# headers would produce an SDK that no core+media pair can reproduce. Those two
# cases still fail the build.
set -euo pipefail

DIR=$1
SNAP=$2
MODE=$3

if [ ! -d "$DIR" ]; then
  echo "sysroot-guard: '$DIR' absent, skipping ($MODE)"
  exit 0
fi

if command -v sha1sum >/dev/null 2>&1; then HASH=(sha1sum); else HASH=(shasum -a 1); fi
checksum() { find "$DIR" -type f -print0 | sort -z | xargs -0 "${HASH[@]}"; }

case "$MODE" in
  snapshot) checksum > "$SNAP" ;;
  verify)
    checksum > "$SNAP.after"
    # Lines present before but not after: either the file is gone, or its
    # content changed (the hash is part of the line). Either way the core
    # artifact no longer is what the core build produced.
    if ! violations=$(comm -23 <(sort "$SNAP") <(sort "$SNAP.after")) || [ -n "$violations" ]; then
      echo "::error::media build changed or removed core files in '$DIR':" >&2
      printf '%s\n' "$violations" >&2
      exit 1
    fi
    added=$(comm -13 <(sort "$SNAP") <(sort "$SNAP.after") | wc -l | tr -d ' ')
    echo "sysroot-guard: '$DIR' core files intact ($added file(s) added by the media build)"
    ;;
  *) echo "sysroot-guard: unknown mode '$MODE'" >&2; exit 1 ;;
esac
