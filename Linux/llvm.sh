#!/bin/bash

source ./common.sh

(

# LLVM 13 only supports being built from llvm 11 / 12 or gcc 11 which isn't supported on centos:7. 
# So first bootstrap llvm 12...
(
  cd llvm 
  $GIT checkout release/12.x
)

mkdir -p llvm-build-12
cd llvm-build-12
$CMAKE -GNinja \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
 -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_CXX_STD="c++17" \
 -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
 -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
 -DLIBCXX_ABI_UNSTABLE=ON \
 -DLIBCXX_USE_COMPILER_RT=OFF \
 -DLIBCXXABI_USE_COMPILER_RT=OFF \
 -DLIBUNWIND_USE_COMPILER_RT=OFF \
 -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;lld;polly" \
 -DCMAKE_INSTALL_PREFIX=$SDK_ROOT/llvm-bootstrap-12 \
 ../llvm/llvm

$CMAKE --build .
$CMAKE --build . --target install/strip
)

(
# Once we have llvm 12 build llvm 13...
(
  cd llvm 
  $GIT checkout release/13.x
)

export PATH=$SDK_ROOT/llvm-bootstrap-12/bin:$PATH
export LD_LIBRARY_PATH=$SDK_ROOT/llvm-bootstrap-12/lib:$LD_LIBRARY_PATH

mkdir -p llvm-build-13
cd llvm-build-13
$CMAKE -GNinja \
 -DCMAKE_C_COMPILER=$SDK_ROOT/llvm-bootstrap-12/bin/clang \
 -DCMAKE_CXX_COMPILER=$SDK_ROOT/llvm-bootstrap-12/bin/clang++ \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
 -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_CXX_STD="c++20" \
 -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
 -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
 -DLIBCXX_ABI_UNSTABLE=ON \
 -DLIBCXX_USE_COMPILER_RT=OFF \
 -DLIBCXXABI_USE_COMPILER_RT=OFF \
 -DLIBUNWIND_USE_COMPILER_RT=OFF \
 -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;lld;polly" \
 -DCMAKE_INSTALL_PREFIX=$SDK_ROOT/llvm-bootstrap \
 ../llvm/llvm

$CMAKE --build .
$CMAKE --build . --target install/strip
)

# LLVM is bootstrapped so that it is all built with the same libc++ version
(
mkdir -p llvm-build
cd llvm-build
export PATH=$SDK_ROOT/llvm-bootstrap/bin:$PATH
export LD_LIBRARY_PATH=$SDK_ROOT/llvm-bootstrap/lib:$LD_LIBRARY_PATH

$CMAKE -GNinja \
 -DCMAKE_C_COMPILER=$SDK_ROOT/llvm-bootstrap/bin/clang \
 -DCMAKE_CXX_COMPILER=$SDK_ROOT/llvm-bootstrap/bin/clang++ \
 -DCMAKE_C_FLAGS="$CFLAGS" \
 -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=0 \
 -DLLVM_INCLUDE_TOOLS=1 \
 -DLLVM_BUILD_TOOLS=1 \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_CXX_STD="c++20" \
 -DLLVM_TARGETS_TO_BUILD="X86;WebAssembly" \
 -DLLVM_ENABLE_LIBCXX=ON \
 -DLLVM_ENABLE_LLD=ON \
 -DLLVM_ENABLE_EH=ON \
 -DLLVM_ENABLE_RTTI=ON \
 -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;lld;polly" \
 -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
 -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
 -DLIBCXX_ABI_UNSTABLE=ON \
 -DLIBCXX_USE_COMPILER_RT=OFF \
 -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
 -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
 -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
 -DLIBCXXABI_USE_COMPILER_RT=OFF \
 -DLIBUNWIND_USE_COMPILER_RT=OFF \
 -DCOMPILER_RT_USE_BUILTINS_LIBRARY=OFF \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/llvm \
 ../llvm/llvm

$CMAKE --build .
$CMAKE --build . --target install/strip
)
