#!/bin/bash
brew install subversion

(
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
cd ../..
cd llvm/tools/clang/tools
svn co http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra
cd ../../../..
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/lld/trunk lld
cd ../..
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/polly/trunk polly
cd ../..

cd llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/openmp/trunk openmp
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
cd ../..
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi
cd ../..
)

cmake \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_INCLUDE_TOOLS=1 \
 -DLLVM_BUILD_TOOLS=1 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
 -G Ninja \
 -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_ENABLE_CXX1Y=1 \
 -DCMAKE_C_FLAGS="-mmacosx-version-min=10.12" \
 -DCMAKE_CXX_FLAGS="-mmacosx-version-min=10.12" \
 -DCMAKE_INSTALL_PREFIX=/opt/score-sdk/llvm \
 ../llvm

ninja
ninja install
