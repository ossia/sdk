#!/bin/bash

source ./common.sh

$GIT clone https://github.com/llvm/llvm-project.git llvm
(
    cd llvm
    $GIT checkout llvmorg-16.0.1
    # $GIT cherry-pick 6d2b75e0887ee87e247756c4d51733616bb2f356
)
