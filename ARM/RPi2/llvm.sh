#!/bin/bash -eux

source /image/config.sh
apt -y install subversion

cd /image
svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_800/final llvm
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_800/final clang
cd ../..

#~ cd llvm/tools/clang/tools
#~ svn co http://llvm.org/svn/llvm-project/clang-tools-extra/tags/RELEASE_800/final extra
#~ cd ../../../..

#~ cd llvm/tools
#~ svn co http://llvm.org/svn/llvm-project/lld/tags/RELEASE_800/final lld
#~ cd ../..

cd llvm/tools
svn co http://llvm.org/svn/llvm-project/polly/tags/RELEASE_800/final polly
cd ../..

#~ cd llvm/tools
#~ svn co http://llvm.org/svn/llvm-project/lldb/tags/RELEASE_800/final lldb
#~ cd ../..

#~ cd llvm/projects
#~ svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_800/final compiler-rt
#~ cd ../..

#~ cd llvm/projects
#~ svn co http://llvm.org/svn/llvm-project/openmp/tags/RELEASE_800/final openmp
#~ cd ../..

#~ cd llvm/projects
#~ svn co http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_800/final libcxx
#~ cd ../..

#~ cd llvm/projects
#~ svn co http://llvm.org/svn/llvm-project/libcxxabi/tags/RELEASE_800/final libcxxabi
#~ cd ../..

mkdir build
cd build

/usr/local/bin/cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_INCLUDE_TOOLS=1 \
    -DLLVM_BUILD_TOOLS=1 \
    -DBUILD_SHARED_LIBS=0 \
    -DLLVM_TARGETS_TO_BUILD="ARM" \
    -DLLVM_INCLUDE_EXAMPLES=0  \
    -DLLVM_INCLUDE_TESTS=0  \
    -DLLVM_ENABLE_CXX1Y=1  \
    -DLLVM_ENABLE_CXX1Z=1 \
    -DLLVM_ENABLE_EH=ON \
    -DLLVM_ENABLE_RTTI=ON \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    ../llvm
    
/usr/local/bin/cmake --build . -- -j$(nproc)
/usr/local/bin/cmake --build . --target install
