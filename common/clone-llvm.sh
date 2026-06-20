#!/bin/bash

source ../common/versions.sh

if [[ ! -d llvm ]]; then
(
    # Shallow clones need the tag up front (-b); full clones keep the original
    # default-branch-then-checkout behaviour for local development.
    git clone $SDK_CLONE_DEPTH ${SDK_CLONE_DEPTH:+-b "$LLVM_VERSION"} https://github.com/llvm/llvm-project.git llvm
    cd llvm
    git checkout $LLVM_VERSION
)
fi