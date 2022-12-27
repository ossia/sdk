#!/bin/bash -eux

source ./common.sh
#
# (
# mkdir -p llvm-build
# cd llvm-build
# $CMAKE -GNinja \
#  -DCMAKE_BUILD_TYPE=Release \
#  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
#  -DLLVM_TARGETS_TO_BUILD="X86" \
#  -DLLVM_INCLUDE_EXAMPLES=0 \
#  -DLLVM_INCLUDE_TESTS=0 \
#  -DLLVM_ENABLE_CXX1Z=1 \
#  -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
#  -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
#  -DLIBCXX_ABI_UNSTABLE=ON \
#  -DLIBCXX_USE_COMPILER_RT=OFF \
#  -DLIBCXXABI_USE_COMPILER_RT=OFF \
#  -DLIBUNWIND_USE_COMPILER_RT=OFF \
#  -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;libunwind;lld;polly" \
#  -DCMAKE_INSTALL_PREFIX=$SDK_ROOT/llvm-bootstrap \
#  ../llvm/llvm
#
# $CMAKE --build .
# $CMAKE --build . --target install/strip
# )
#
# LLVM is bootstrapped so that it is all built with the same libc++ version
(
rm -rf llvm-build
mkdir -p llvm-build
cd llvm-build
#export PATH=$SDK_ROOT/llvm-bootstrap/bin:$PATH
#export LD_LIBRARY_PATH=$SDK_ROOT/llvm-bootstrap/lib:$LD_LIBRARY_PATH

$CMAKE -GNinja \
 -DCMAKE_CROSSCOMPILING=True \
 -DLLVM_TABLEGEN=/usr/bin/llvm-tblgen \
 -DLLVM_DEFAULT_TARGET_TRIPLE=$LLVM_DEFAULT_TARGET_TRIPLE \
 -DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH \
 -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
 -DCMAKE_C_FLAGS="$CFLAGS" \
 -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=0 \
 -DLLVM_INCLUDE_TOOLS=1 \
 -DLLVM_BUILD_TOOLS=1 \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_INCLUDE_BENCHMARKS=0 \
 -DLLVM_ENABLE_CXX1Z=1 \
 -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGET" \
 -DLLVM_ENABLE_EH=ON \
 -DLLVM_ENABLE_RTTI=ON \
 -DLLVM_ENABLE_PROJECTS="" \
 -DLLVM_ENABLE_OCAMLDOC=OFF \
 -DLLVM_ENABLE_BINDINGS=0 \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/llvm \
 ../llvm/llvm

$CMAKE --build .
$CMAKE --build . --target install/strip
)
