#!/bin/bash

source ./common.sh

LLVM_VERSION=tags/RELEASE_701/rc2
(
svn co http://llvm.org/svn/llvm-project/llvm/$LLVM_VERSION llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/$LLVM_VERSION clang
cd ../..
cd llvm/tools/clang/tools
svn co http://llvm.org/svn/llvm-project/clang-tools-extra/$LLVM_VERSION extra
cd ../../../..
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/lld/$LLVM_VERSION lld
cd ../..
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/polly/$LLVM_VERSION polly
cd ../..

cd llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/$LLVM_VERSION compiler-rt
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/openmp/$LLVM_VERSION openmp
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/libcxx/$LLVM_VERSION libcxx
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/libcxxabi/$LLVM_VERSION libcxxabi
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/libunwind/$LLVM_VERSION libunwind
cd ../..
)
