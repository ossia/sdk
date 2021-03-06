#!/bin/bash

source ./common.sh

git clone https://github.com/llvm/llvm-project.git llvm
(
    cd llvm
    git checkout release/11.x
    git cherry-pick 6d2b75e0887ee87e247756c4d51733616bb2f356
)
