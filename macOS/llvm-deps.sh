#!/bin/bash

source ./common.sh

git clone https://github.com/llvm/llvm-project.git llvm
(
    cd llvm
    git checkout release/14.x
)
