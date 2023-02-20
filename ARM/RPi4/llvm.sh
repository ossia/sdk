#!/bin/bash -eux

source ./common.sh gcc

if [[ ! -f ./llvm-build-host/bin/clang-tblgen ]]; then
(
  unset CC
  unset CXX
  unset CFLAGS
  unset CXXFLAGS
  mkdir -p llvm-build-host
  cd llvm-build-host
  $CMAKE  -GNinja \
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
   -DCLANG_DEFAULT_RTLIB:STRING=libgcc \
   -DCLANG_DEFAULT_CXX_STDLIB:STRING=libstdc++ \
   -DCLANG_DEFAULT_LINKER:STRING=lld \
   -DLLVM_ENABLE_PROJECTS="clang;lld;polly;openmp" \
   -DCMAKE_INSTALL_PREFIX=$SDK_INSTALL_ROOT/llvm \
   ../llvm/llvm
  
  $CMAKE --build .
  $CMAKE --build . --target install/strip
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
# LLVM is bootstrapped so that it is all built with the same libc++ version
(
rm -rf llvm-build
mkdir -p llvm-build
cd llvm-build
#export PATH=$SDK_ROOT/llvm-bootstrap/bin:$PATH
#export LD_LIBRARY_PATH=$SDK_ROOT/llvm-bootstrap/lib:$LD_LIBRARY_PATH

$CMAKE -GNinja \
 -DCMAKE_CROSSCOMPILING=True \
 -DLLVM_TABLEGEN=$SDK_INSTALL_ROOT/llvm \
 -DCLANG_TABLEGEN=$SDK_ROOT/llvm-build-host/bin/clang-tblgen \
 -DLLVM_DEFAULT_TARGET_TRIPLE=$LLVM_DEFAULT_TARGET_TRIPLE \
 -DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH \
 -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGET" \
 -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="$LLVM_TARGET" \
 -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
 -DCMAKE_C_FLAGS="$CFLAGS" \
 -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SHARED_LIBS=0 \
 -DLLVM_ENABLE_LIBCXX=1 \
 -DLLVM_INCLUDE_TOOLS=0 \
 -DLLVM_BUILD_TOOLS=0 \
 -DLLVM_INCLUDE_EXAMPLES=0 \
 -DLLVM_INCLUDE_TESTS=0 \
 -DLLVM_INCLUDE_BENCHMARKS=0 \
 -DLLVM_ENABLE_CXX1Z=1 \
 -DLLVM_ENABLE_EH=ON \
 -DLLVM_ENABLE_RTTI=ON \
 -DLLVM_ENABLE_PROJECTS="clang;polly" \
 -DLLVM_ENABLE_OCAMLDOC=OFF \
 -DLLVM_ENABLE_BINDINGS=0 \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/llvm-libs \
 ../llvm/llvm

$CMAKE --build .
# $CMAKE --build . --target install/strip
)


(
  # Clear the libs
  for file in ./bugpoint ./c-index-test ./clang-14 ./clang-check ./clang-extdef-mapping ./clang-format ./clang-linker-wrapper ./clang-nvlink-wrapper ./clang-offload-bundler ./clang-offload-wrapper ./clang-refactor ./clang-rename ./clang-repl ./clang-scan-deps ./diagtool ./dsymutil ./llc ./lli ./llvm-ar ./llvm-as ./llvm-bcanalyzer ./llvm-cat ./llvm-cfi-verify ./llvm-cov ./llvm-c-test ./llvm-cvtres ./llvm-cxxdump ./llvm-cxxfilt ./llvm-cxxmap ./llvm-debuginfod-find ./llvm-diff ./llvm-dis ./llvm-dwarfdump ./llvm-dwp ./llvm-exegesis ./llvm-extract ./llvm-gsymutil ./llvm-ifs ./llvm-jitlink ./llvm-libtool-darwin ./llvm-link ./llvm-lipo ./llvm-lto ./llvm-lto2 ./llvm-mc ./llvm-mca ./llvm-ml ./llvm-modextract ./llvm-mt ./llvm-nm ./llvm-objcopy ./llvm-objdump ./llvm-omp-device-info ./llvm-opt-report ./llvm-pdbutil ./llvm-profdata ./llvm-profgen ./llvm-rc ./llvm-readobj ./llvm-reduce ./llvm-rtdyld ./llvm-sim ./llvm-size ./llvm-split ./llvm-stress ./llvm-strings ./llvm-symbolizer ./llvm-tapi-diff ./llvm-tblgen ./llvm-tli-checker ./llvm-undname ./llvm-xray ./opt ./sancov ./sanstats ./split-file ./verify-uselistorder ; do 
    echo '1' > $INSTALL_PREFIX/llvm-libs/bin/$file
  done

)