#!/usr/bin/env bash
# Resolve the core SDK for a media build and download it into $DEST from the
# single rolling master-core prerelease.
# Usage: resolve-core.sh <release_tag> <asset_name> <dest_dir> <is_master> <expected_hash>
# Requires: gh (GH_TOKEN). Emits "mode=<download|skip|inline>" to $GITHUB_OUTPUT:
#   download : the core asset was fetched into $DEST (and, if a hash was given,
#              matches this build's core inputs)
#   skip     : master build, matching core not published yet -> defer to the
#              core->media cascade (this run no-ops, no red X)
#   inline   : PR/dispatch with no matching core -> build full (core+media)
set -euo pipefail

RELEASE_TAG=$1
ASSET=$2
DEST=$3
IS_MASTER=${4:-false}
EXPECT_HASH=${5:-}

mkdir -p "$DEST"
emit() { echo "mode=$1" >> "${GITHUB_OUTPUT:-/dev/stdout}"; echo ">> resolve-core mode: $1"; }

# Pull this platform/arch's core asset (and its .sha sidecar) from the one
# rolling release.
if gh release download "$RELEASE_TAG" -p "$ASSET" -p "$ASSET.sha" -D "$DEST" 2>/dev/null \
     && [ -f "$DEST/$ASSET" ]; then
  got_hash=$(tr -d '[:space:]' < "$DEST/$ASSET.sha" 2>/dev/null || true)
  if [ -z "$EXPECT_HASH" ] || [ "$got_hash" = "$EXPECT_HASH" ]; then
    echo "Resolved core '$ASSET' from '$RELEASE_TAG' (hash ${got_hash:-n/a})."
    emit download; exit 0
  fi
  # The published core is from an older master build whose inputs differ from
  # this one. Don't build media against the wrong core.
  echo "::warning::core '$ASSET' in '$RELEASE_TAG' has hash '$got_hash', expected '$EXPECT_HASH'."
  rm -f "$DEST/$ASSET"
fi

# Legacy path: with the core->media cascade this deferred to it. sdk.yml runs
# media after core in the same run and always passes is_master=false, so this
# branch is unused there; it is kept for manual/monolithic callers.
if [ "$IS_MASTER" = "true" ]; then
  echo "::warning::matching core not published to '$RELEASE_TAG' yet; deferring to the core->media cascade."
  emit skip; exit 0
fi

# PR / dispatch: no matching published core -> build core inline.
echo "::warning::no matching published core in '$RELEASE_TAG'; building core inline (STAGE=full)."
emit inline
