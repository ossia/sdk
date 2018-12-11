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
)

(
mkdir -p llvm-build
cd llvm-build
cmake \
 -G Ninja \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
 -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_ENABLE_CXX1Z=1 \
 -DCMAKE_INSTALL_PREFIX=$SDK_ROOT/llvm-bootstrap \
 ../llvm

ninja
ninja install
)

# LLVM is bootstrapped so that it is all built with the same libc++ version
(
rm -rf llvm-build
mkdir -p llvm-build
cd llvm-build
set PATH=$SDK_ROOT/llvm-bootstrap/bin:$PATH

cmake \
 -G Ninja \
 -DCMAKE_C_COMPILER=$SDK_ROOT/llvm-bootstrap/bin/clang \
 -DCMAKE_CXX_COMPILER=$SDK_ROOT/llvm-bootstrap/bin/clang++ \
 -DCMAKE_C_FLAGS="-mmacosx-version-min=$MACOS_VERSION" \
 -DCMAKE_CXX_FLAGS="-mmacosx-version-min=$MACOS_VERSION" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_OSX_ARCHITECTURES=x86_64 \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
 -DBUILD_SHARED_LIBS=0 \
 -DLLVM_INCLUDE_TOOLS=1 \
 -DLLVM_BUILD_TOOLS=1 \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_ENABLE_CXX1Z=1 \
 -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_ENABLE_LIBCXX=ON \
 -DLLVM_ENABLE_LLD=ON \
 -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
 -DLIBCXX_ABI_UNSTABLE=ON \
 -DLIBCXX_USE_COMPILER_RT=ON \
 -DLIBCXXABI_USE_COMPILER_RT=ON \
 -DCOMPILER_RT_ENABLE_IOS=OFF \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/llvm \
 ../llvm

ninja
ninja install
)