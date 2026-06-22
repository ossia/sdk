#!/bin/bash

source ../common/versions.sh

# Local patches applied on top of the pinned LLVM release (see common/patches/).
LLVM_PATCHES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/patches" && pwd)"

if [[ ! -d llvm ]]; then
(
    # Shallow clones need the tag up front (-b); full clones keep the original
    # default-branch-then-checkout behaviour for local development.
    git clone $SDK_CLONE_DEPTH ${SDK_CLONE_DEPTH:+-b "$LLVM_VERSION"} https://github.com/llvm/llvm-project.git llvm
    cd llvm
    git checkout $LLVM_VERSION

    # Apply our LLVM patches (JITLink COFF fix for the score JIT, etc.).
    for p in "$LLVM_PATCHES_DIR"/*.patch; do
        [ -e "$p" ] || continue
        echo "Applying LLVM patch: $(basename "$p")"
        git apply -p1 "$p"
    done
)
fi