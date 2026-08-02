#!/usr/bin/env bash
# Publish a core SDK tarball as an asset on the single rolling master-core
# prerelease (one release for the whole current-master build, not one per
# artefact). Alongside the tarball we upload a tiny "<asset>.sha" sidecar
# holding the content hash, so the core-* jobs can skip an unchanged rebuild
# (see core-published.sh) and media can verify it got the right core.
#
# Usage: publish-core.sh <release_tag> <asset_file> <core_hash>
# Requires: gh (authenticated via GH_TOKEN), $GITHUB_SHA in the environment.
set -euo pipefail

RELEASE_TAG=$1
FILE=$2
CORE_HASH=$3

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

# Ensure the single rolling release exists. All (up to) six core legs run this
# concurrently: the create is racy but idempotent -- whoever loses the race sees
# the release already there and moves on. The actual uploads below go to
# distinct per-(platform,arch) asset names, so they never collide.
for i in 1 2 3 4 5; do
  if gh release view "$RELEASE_TAG" >/dev/null 2>&1; then
    break
  fi
  if gh release create "$RELEASE_TAG" --prerelease \
       --title "SDK core (continuous master build)" \
       --notes "Rolling core artefacts for the current master branch. Replaced on every master build; not a stable release -- use the sdkNN tags for that." \
       --target "${GITHUB_SHA:-master}" 2>/dev/null; then
    break
  fi
  sleep $((i * 2))
done

# Upload the tarball and its hash sidecar, clobbering the previous master build's
# assets for this platform/arch.
base=$(basename "$FILE")
printf '%s\n' "$CORE_HASH" > "$base.sha"
gh release upload "$RELEASE_TAG" "$FILE" "$base.sha" --clobber
rm -f "$base.sha"

echo "Published $base (hash $CORE_HASH) to release '$RELEASE_TAG'."
