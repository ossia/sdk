#!/bin/bash -eu

source ./common.sh
source ../common/clone-llvm.sh
# LLVM is bootstrapped so that it is all built with the same libc++ version
(
mkdir -p llvm-build-3
cd llvm-build-3
# set PATH=/opt/score-sdk/llvm/bin:$PATH

xcrun --sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk cmake -Wno-dev \
 -GNinja \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=0 \
 -DLLVM_INCLUDE_TOOLS=1 \
 -DLLVM_BUILD_TOOLS=1 \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_ENABLE_CXX1Z=1 \
 -DLLVM_ENABLE_LIBEDIT=0 \
 -DLLVM_ENABLE_TERMINFO=0 \
 -DLLVM_TARGETS_TO_BUILD="$LLVM_ARCH" \
 -DLLVM_ENABLE_LIBCXX=OFF \
 -DLLVM_ENABLE_LLD=OFF \
 -DLLVM_ENABLE_RTTI=ON \
 -DLLVM_ENABLE_ZLIB=ON \
 -DLLVM_ENABLE_ZSTD=OFF \
 -DLLVM_ENABLE_EH=ON \
 -DLLVM_ENABLE_PROJECTS="clang;polly" \
 -DCMAKE_CXX_STANDARD=20 \
 -DCOMPILER_RT_ENABLE_IOS=OFF \
 -DCMAKE_OSX_ARCHITECTURES=$MACOS_ARCH \
 -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/llvm-libs \
  $CMAKE_ADDITIONAL_FLAGS \
 ../llvm/llvm
# -DCMAKE_SHARED_LINKER_FLAGS="-L$INSTALL_PREFIX/llvm/lib -lc++ -lc++abi -Wl,-rpath,$INSTALL_PREFIX/llvm/lib" \
# -DCMAKE_EXE_LINKER_FLAGS="-L$INSTALL_PREFIX/llvm/lib -lc++ -lc++abi -Wl,-rpath,$INSTALL_PREFIX/llvm/lib" \
# -DCMAKE_MODULE_LINKER_FLAGS="-L$INSTALL_PREFIX/llvm/lib -lc++ -lc++abi -Wl,-rpath,$INSTALL_PREFIX/llvm/lib" \

xcrun cmake --build . --parallel
xcrun cmake --build . --parallel --target install/strip

)
