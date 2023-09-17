#!/bin/bash -eux

source ./common.sh gcc
source ../common/clone-llvm.sh

curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.4/clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04.tar.xz -o llvm.txz
tar xaf llvm.txz
mv 'clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04' $SDK_INSTALL_ROOT/pi/llvm-16

curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.4/clang+llvm-16.0.4-aarch64-linux-gnu.tar.xz -o llvm-aarch.txz
tar xaf llvm-aarch.txz
mv 'clang+llvm-16.0.4-aarch64-linux-gnu' $SDK_INSTALL_ROOT/pi/llvm-16-aarch64

if [[ ! -f ./llvm-build-host/bin/clang-tblgen ]]
then
(
  unset CC
  unset CXX
  unset CFLAGS
  unset CXXFLAGS
  $CMAKE -S llvm -B llvm-build-host \
   -GNinja \
   -DCMAKE_C_COMPILER=/usr/bin/clang \
   -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
   -DLLVM_ENABLE_CURSES=0 \
   -DLLVM_ENABLE_TERMINFO=0 \
   -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGET" \
   -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="$LLVM_TARGET" \
   -DLLVM_DEFAULT_TARGET_TRIPLE=$LLVM_DEFAULT_TARGET_TRIPLE \
   -DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH \
   -DLLVM_INCLUDE_EXAMPLES=0 \
   -DLLVM_INCLUDE_TESTS=0 \
   -DLLVM_ENABLE_OCAMLDOC=OFF \
   -DLLVM_ENABLE_BINDINGS=0 \
   -DLLVM_INCLUDE_BENCHMARKS=0 \
   -DLLVM_CXX_STD="c++20" \
   -DLLVM_ENABLE_EH=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLIBCXX_ENABLE_STATIC=ON \
   -DLIBCXX_ENABLE_SHARED=OFF \
   -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
   -DLIBCXX_ENABLE_SHARED_ABI_LIBRARY=OFF \
   -DLIBCXX_ABI_ENABLE_STATIC=ON \
   -DLIBCXX_ABI_UNSTABLE=ON \
   -DLIBCXX_USE_COMPILER_RT=OFF \
   -DLIBCXXABI_USE_COMPILER_RT=OFF \
   -DLIBUNWIND_USE_COMPILER_RT=OFF \
   -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
   -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
   -DCLANG_DEFAULT_LINKER:STRING=lld \
   -DLLVM_ENABLE_PROJECTS="clang;lld;polly;openmp" \
   -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
   -DCMAKE_INSTALL_PREFIX=$SDK_INSTALL_ROOT/llvm
  
  $CMAKE --build llvm-build-host
  $CMAKE --build llvm-build-host --target install/strip
)
fi

exit 0
# Version with libc++, does not work yet
# We need this for llvm-tblgen and clang-tblgen 
# if [[ ! -f ./llvm-build-host/bin/clang-tblgen ]]; then
# (
#   unset CC
#   unset CXX
#   unset CFLAGS
#   unset CXXFLAGS
#   mkdir -p llvm-build-host
#   cd llvm-build-host
#   $CMAKE  -GNinja \
#    -DCMAKE_C_COMPILER=/usr/bin/clang \
#    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
#    -DLLVM_ENABLE_CURSES=0 \
#    -DLLVM_ENABLE_TERMINFO=0 \
#    -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGET" \
#    -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="$LLVM_TARGET" \
#    -DLLVM_DEFAULT_TARGET_TRIPLE=$LLVM_DEFAULT_TARGET_TRIPLE \
#    -DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH \
#    -DLLVM_INCLUDE_EXAMPLES=0 \
#    -DLLVM_INCLUDE_TESTS=0 \
#    -DLLVM_ENABLE_OCAMLDOC=OFF \
#    -DLLVM_ENABLE_BINDINGS=0 \
#    -DLLVM_INCLUDE_BENCHMARKS=0 \
#    -DLLVM_CXX_STD="c++20" \
#    -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
#    -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
#    -DCLANG_DEFAULT_LINKER:STRING=lld \
#    -DLLVM_ENABLE_PROJECTS="clang;lld;polly;openmp;libcxx;libcxxabi" \
#    -DLIBCXX_ABI_UNSTABLE=ON \
#    -DLIBCXX_USE_COMPILER_RT=OFF \
#    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=OFF \
#    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
#    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=OFF \
#    -DLIBCXXABI_USE_COMPILER_RT=OFF \
#    -DLIBUNWIND_USE_COMPILER_RT=OFF \
#    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=OFF \
#    -DCMAKE_INSTALL_PREFIX=$SDK_INSTALL_ROOT/llvm \
#    ../llvm/llvm
#   
#   $CMAKE --build .
#   $CMAKE --build . --target install/strip
# )
# fi

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
