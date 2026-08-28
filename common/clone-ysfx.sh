#!/bin/bash

source ../common/versions.sh
YSFX_PATCHES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/ysfx-patches" && pwd)"

if [[ ! -d ysfx ]]; then
(
  git clone --recursive $SDK_CLONE_DEPTH $SDK_SHALLOW_SUBMODULES https://github.com/jcelerier/ysfx -b ossia/2026-01
  (
    cd ysfx
    for p in "$YSFX_PATCHES_DIR"/*.patch; do
      [[ -e "$p" ]] || continue
      if git apply --check "$p" 2>/dev/null; then
        git apply "$p"
        echo "clone-ysfx: applied $(basename "$p")"
      elif git apply --reverse --check "$p" 2>/dev/null; then
        echo "clone-ysfx: $(basename "$p") already present, skipping"
      else
        echo "clone-ysfx: $(basename "$p") does not apply" >&2
        exit 1
      fi
    done
  )
)
fi
