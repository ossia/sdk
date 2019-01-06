#!/bin/bash

source ./common.sh

yum -y update
yum -y install epel-release  centos-release-scl devtoolset-7
yum -y update
yum -y install ninja-build wget flex bison rsync bzip2 make xz file \
           svn perl-Data-Dump perl-Data-Dumper \
           perl harfbuzz-devel which make perl-version libxcb libxcb-devel xcb-util xcb-util-devel fontconfig-devel libX11-devel libXrender-devel libXi-devel git dbus-devel glib2-devel mesa-libGL-devel openssl-devel
scl enable devtoolset-7 bash

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

(
mkdir -p llvm-build
cd llvm-build
cmake \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
 -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_ENABLE_CXX1Z=1 \
 -DCLANG_DEFAULT_CXX_STDLIB:STRING=libc++ \
 -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
 -DLIBCXX_ABI_UNSTABLE=ON \
 -DLIBCXX_USE_COMPILER_RT=OFF \
 -DLIBCXXABI_USE_COMPILER_RT=OFF \
 -DLIBUNWIND_USE_COMPILER_RT=OFF \
 -DCMAKE_INSTALL_PREFIX=$SDK_ROOT/llvm-bootstrap \
 ../llvm

make -j$NPROC
make install/strip
)

# LLVM is bootstrapped so that it is all built with the same libc++ version
(
rm -rf llvm-build
mkdir -p llvm-build
cd llvm-build
export PATH=$SDK_ROOT/llvm-bootstrap/bin:$PATH

cmake \
 -DCMAKE_C_COMPILER=$SDK_ROOT/llvm-bootstrap/bin/clang \
 -DCMAKE_CXX_COMPILER=$SDK_ROOT/llvm-bootstrap/bin/clang++ \
 -DCMAKE_C_FLAGS="-O3" \
 -DCMAKE_CXX_FLAGS="-O3" \
 -DCMAKE_BUILD_TYPE=Release \
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
 ../llvm

make -j$NPROC
make install/strip
)