#!/bin/bash

#source ./common.sh
SDK_ROOT=$PWD
INSTALL_PREFIX=$(cat common.sh| grep PREFIX= | cut -d '=' -f 2)

cmake -G Ninja -S runtimes -B build 
-DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"  
-DCMAKE_BUILD_TYPE=Debug 
-DLIBCXX_ENABLE_SHARED=NO
 -DLIBCXX_ENABLE_STATIC=YES
 -DLIBCXX_INSTALL_LIBRARY=1 
 -DLIBCXX_INSTALL_HEADERS=1
 -DLIBCXX_ENABLE_ASSERTIONS=1
 -DCMAKE_INSTALL_PREFIX=/opt/libcxx-14/
 -DLIBCXX_HERMETIC_STATIC_LIBRARY=1
 -DLIBCXX_CXX_ABI=system-libcxxabi 
 -DLIBCXX_INCLUDE_TESTS=0 
 -DLIBCXX_INCLUDE_BENCHMARKS=0 
 -DLIBCXX_ENABLE_DEBUG_MODE_SUPPORT=1 
 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.11

ninja -C build cxx cxxabi unwind
ninja -C build install-cxx install-cxxabi install-unwind
