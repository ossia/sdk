#!/usr/bin/env bash
# Resolve the core SDK for a media build and download it into $DEST.
# Usage: resolve-core.sh <core_tag> <latest_tag> <asset_glob> <dest_dir> <is_master>
# Requires: gh (GH_TOKEN). Emits "mode=<download|skip|inline>" to $GITHUB_OUTPUT:
#   download : the matching (or rolling) core was fetched into $DEST
#   skip     : master build, exact core not published yet -> defer to the
#              core->media cascade (this run no-ops, no red X)
#   inline   : PR/dispatch with no published core -> build full (core+media)
set -euo pipefail

CORE_TAG=$1
LATEST_TAG=$2
GLOB=$3
DEST=$4
IS_MASTER=${5:-false}

mkdir -p "$DEST"
emit() { echo "mode=$1" >> "${GITHUB_OUTPUT:-/dev/stdout}"; echo ">> resolve-core mode: $1"; }

# Fast path: the exact content-hashed core for this commit's inputs.
if gh release download "$CORE_TAG" -p "$GLOB" -D "$DEST" 2>/dev/null \
     && ls "$DEST"/$GLOB >/dev/null 2>&1; then
  echo "Resolved core: $CORE_TAG"
  emit download; exit 0
fi

# On a master / cascade build the exact core must exist; if it doesn't, core.yml
# is (re)building it right now, so defer rather than fail.
if [ "$IS_MASTER" = "true" ]; then
  echo "::warning::core '$CORE_TAG' not published yet; deferring to the core->media cascade."
  emit skip; exit 0
fi

# PR / dispatch fallback: the rolling pointer names the latest master core.
echo "::warning::core '$CORE_TAG' not found; trying rolling '$LATEST_TAG'."
if gh release download "$LATEST_TAG" -p core_tag.txt -D . 2>/dev/null; then
  fb=$(tr -d '[:space:]' < core_tag.txt || true); rm -f core_tag.txt
  if [ -n "${fb:-}" ] && gh release download "$fb" -p "$GLOB" -D "$DEST" 2>/dev/null \
       && ls "$DEST"/$GLOB >/dev/null 2>&1; then
    echo "::warning::using rolling core '$fb' (may differ from this PR's core inputs)."
    emit download; exit 0
  fi
fi

echo "::warning::no published core available; building core inline (STAGE=full)."
emit inline
