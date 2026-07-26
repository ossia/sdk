#!/usr/bin/env bash
# Publish a FULL SDK artefact (the repository's actual deliverable: core+media
# merged) as an asset on a GitHub release.
#   - master builds  -> the rolling "continuous" prerelease (is_rolling=true)
#   - tag builds      -> that tag's release, e.g. sdk38 (is_rolling=false)
# Usage: publish-sdk.sh <release_tag> <asset_file> <is_rolling>
# Requires: gh (authenticated via GH_TOKEN), $GITHUB_SHA in the environment.
set -euo pipefail

RELEASE_TAG=$1
FILE=$2
IS_ROLLING=${3:-false}

if [[ ! -f "$FILE" ]]; then
  echo "::error::publish-sdk: asset '$FILE' not found" >&2
  exit 1
fi

# Size guard (gotcha G5): a single GitHub release asset must stay < 2 GB.
size=$(wc -c < "$FILE")
if [ "$size" -ge 2000000000 ]; then
  echo "::error::SDK asset '$FILE' is ${size} bytes (>= 2GB asset limit); split the SDK into per-component assets." >&2
  exit 1
fi

# Ensure the target release exists. Concurrency across the (up to) six media legs
# is fine: the create is racy but idempotent, and each leg uploads a distinct
# per-(platform,arch) asset name, so uploads never collide.
#   - rolling: create the prerelease if missing (never clobbers a maintainer's
#     release notes -- if it already exists we just add assets).
#   - tag: if the maintainer has not pre-created the release, create a plain one;
#     otherwise leave their title/notes untouched and only attach assets.
for i in 1 2 3 4 5; do
  if gh release view "$RELEASE_TAG" >/dev/null 2>&1; then
    break
  fi
  if [ "$IS_ROLLING" = "true" ]; then
    gh release create "$RELEASE_TAG" --prerelease \
       --title "SDK (continuous master build)" \
       --notes "Rolling full SDK artefacts for the current master branch. Replaced on every master build; use the sdkNN tags for stable releases." \
       --target "${GITHUB_SHA:-master}" 2>/dev/null && break || true
  else
    gh release create "$RELEASE_TAG" \
       --title "$RELEASE_TAG" \
       --notes "SDK $RELEASE_TAG" \
       --target "${GITHUB_SHA:-master}" 2>/dev/null && break || true
  fi
  sleep $((i * 2))
done

gh release upload "$RELEASE_TAG" "$FILE" --clobber
echo "Published $(basename "$FILE") to release '$RELEASE_TAG'."
