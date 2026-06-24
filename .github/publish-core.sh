#!/usr/bin/env bash
# Publish a core SDK tarball as an asset on a hash-keyed GitHub prerelease.
# Usage: publish-core.sh <core_tag> <asset_file> <latest_tag> <is_master>
# Requires: gh (authenticated via GH_TOKEN), $GITHUB_SHA in the environment.
set -euo pipefail

CORE_TAG=$1
FILE=$2
LATEST_TAG=$3
IS_MASTER=${4:-false}

if [[ ! -f "$FILE" ]]; then
  echo "::error::publish-core: asset '$FILE' not found" >&2
  exit 1
fi

# Size guard (gotcha G5): a single GitHub release asset must stay < 2 GB.
size=$(wc -c < "$FILE")
if [ "$size" -ge 2000000000 ]; then
  echo "::error::core asset '$FILE' is ${size} bytes (>= 2GB asset limit); split llvm into its own asset." >&2
  exit 1
fi

# Create the per-(platform,arch) prerelease if absent, then upload (clobbering
# on re-runs). '|| true' makes a re-run that hits an existing tag a no-op.
gh release create "$CORE_TAG" --prerelease \
  --title "SDK core $CORE_TAG" \
  --notes "Auto-published core build (commit ${GITHUB_SHA:-unknown})." \
  --target "${GITHUB_SHA:-master}" || true
gh release upload "$CORE_TAG" "$FILE" --clobber

# On master, repoint the rolling fallback pointer. To avoid duplicating the big
# asset, the '-latest' release only carries a tiny text file naming the current
# core_tag; media.yml reads it to resolve a fallback core.
if [ "$IS_MASTER" = "true" ]; then
  printf '%s\n' "$CORE_TAG" > core_tag.txt
  gh release create "$LATEST_TAG" --prerelease \
    --title "SDK core (rolling latest)" \
    --notes "Pointer to the most recent core_tag published on master." || true
  gh release upload "$LATEST_TAG" core_tag.txt --clobber
  rm -f core_tag.txt
fi
