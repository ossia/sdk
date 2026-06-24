#!/usr/bin/env bash
# Guard that the media build does NOT mutate an immutable core directory (which
# would mean the shipped SDK depends on a side effect that vanishes on the next
# core rebuild). Usage: sysroot-guard.sh <dir> <snapshot_file> <snapshot|verify>
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
    if ! diff -q "$SNAP" "$SNAP.after" >/dev/null 2>&1; then
      echo "::error::media build mutated immutable core dir '$DIR':" >&2
      diff "$SNAP" "$SNAP.after" >&2 || true
      exit 1
    fi
    echo "sysroot-guard: '$DIR' unchanged across media build"
    ;;
  *) echo "sysroot-guard: unknown mode '$MODE'" >&2; exit 1 ;;
esac
