#!/bin/bash

source ./common.sh

$GIT clone https://github.com/llvm/llvm-project.git llvm
(
    cd llvm
    $GIT checkout release/10.x
)
