#!/bin/bash

source ./common.sh

# Track the same LLVM as the rest of the SDK ($LLVM_VERSION in common/versions.sh)
# instead of the old release/11.x pin. This LLVM is the one Faust links against
# (WASM/faust.sh -> LLVM_DIR=$INSTALL_PREFIX/llvm) to JIT DSP in the browser.
if [[ ! -d llvm ]]; then
  git clone $SDK_CLONE_DEPTH ${SDK_CLONE_DEPTH:+-b "$LLVM_VERSION"} \
    https://github.com/llvm/llvm-project.git llvm
  (
    cd llvm
    git checkout "$LLVM_VERSION"
  )
fi
