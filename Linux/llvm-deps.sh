#!/bin/bash

source ./common.sh

$GIT clone https://github.com/llvm/llvm-project.git llvm
(
    cd llvm
    $GIT checkout release/11.x
    sed -i 's/Diags.isIgnored/!Diags.isIgnored/g' clang/lib/Frontend/CompilerInvocation.cpp
)
