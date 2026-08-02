#!/usr/bin/env bash
# Print "true" if the core asset <asset> is already published on release <tag>
# with a "<asset>.sha" sidecar whose hash matches <want> -- i.e. this exact core
# has been built before and the core-* jobs can skip the (multi-hour) rebuild. Prints
# "false" otherwise (missing release, missing asset, or a stale hash).
# Requires: gh (GH_TOKEN).
set -euo pipefail

TAG=$1
ASSET=$2
WANT=$3

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

got=""
if gh release download "$TAG" -p "$ASSET.sha" -D "$tmp" 2>/dev/null; then
  got=$(tr -d '[:space:]' < "$tmp/$ASSET.sha" 2>/dev/null || true)
fi

if [ -n "$got" ] && [ "$got" = "$WANT" ] \
   && gh release view "$TAG" --json assets -q '.assets[].name' 2>/dev/null | grep -qx "$ASSET"; then
  echo true
else
  echo false
fi
