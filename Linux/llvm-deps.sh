#!/bin/bash

source ./common.sh

$GIT clone https://github.com/llvm/llvm-project.git llvm
(
    cd llvm
    $GIT checkout release/11.x
    $GIT cherry-pick 6d2b75e0887ee87e247756c4d51733616bb2f356
)
