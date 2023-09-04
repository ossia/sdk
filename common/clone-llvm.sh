#!/bin/bash

source ./versions.sh

if [[ ! -d llvm]]; then
(
    git clone https://github.com/llvm/llvm-project.git llvm
    cd llvm
    git checkout $LLVM_VERSION
)
fi