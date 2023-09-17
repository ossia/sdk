#!/bin/bash -eux

source ./common.sh clang


# LLVM is bootstrapped so that it is all built with the same libc++ version
(
mkdir -p llvm-build
cd llvm-build
#export PATH=$SDK_ROOT/llvm-bootstrap/bin:$PATH
#export LD_LIBRARY_PATH=$SDK_ROOT/llvm-bootstrap/lib:$LD_LIBRARY_PATH

$CMAKE -GNinja \
 -DCMAKE_CROSSCOMPILING=True \
 -DLLVM_TABLEGEN=/usr/bin/llvm-tblgen \
 -DLLVM_DEFAULT_TARGET_TRIPLE=$LLVM_DEFAULT_TARGET_TRIPLE \
 -DLLVM_TARGET_ARCH=$LLVM_TARGET_ARCH \
 -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGET" \
 -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="$LLVM_TARGET" \
 -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
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
 -DLLVM_ENABLE_PROJECTS="" \
 -DLLVM_ENABLE_OCAMLDOC=OFF \
 -DLLVM_ENABLE_BINDINGS=0 \
 -DLLVM_STATIC_LINK_CXX_STDLIB=1 \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/llvm-libs \
 -DHAVE_CXX_ATOMICS_WITHOUT_LIB=1 -DHAVE_CXX_ATOMICS64_WITHOUT_LIB=1 \
 ../llvm/llvm

$CMAKE --build .
$CMAKE --build . --target install/strip
)


(
  # Clear the libs
  for file in ./bugpoint ./c-index-test ./clang-1* ./clang-check ./clang-extdef-mapping ./clang-format ./clang-linker-wrapper ./clang-nvlink-wrapper ./clang-offload-bundler ./clang-offload-wrapper ./clang-refactor ./clang-rename ./clang-repl ./clang-scan-deps ./diagtool ./dsymutil ./llc ./lli ./llvm-ar ./llvm-as ./llvm-bcanalyzer ./llvm-cat ./llvm-cfi-verify ./llvm-cov ./llvm-c-test ./llvm-cvtres ./llvm-cxxdump ./llvm-cxxfilt ./llvm-cxxmap ./llvm-debuginfod-find ./llvm-diff ./llvm-dis ./llvm-dwarfdump ./llvm-dwp ./llvm-exegesis ./llvm-extract ./llvm-gsymutil ./llvm-ifs ./llvm-jitlink ./llvm-libtool-darwin ./llvm-link ./llvm-lipo ./llvm-lto ./llvm-lto2 ./llvm-mc ./llvm-mca ./llvm-ml ./llvm-modextract ./llvm-mt ./llvm-nm ./llvm-objcopy ./llvm-objdump ./llvm-omp-device-info ./llvm-opt-report ./llvm-pdbutil ./llvm-profdata ./llvm-profgen ./llvm-rc ./llvm-readobj ./llvm-reduce ./llvm-rtdyld ./llvm-sim ./llvm-size ./llvm-split ./llvm-stress ./llvm-strings ./llvm-symbolizer ./llvm-tapi-diff ./llvm-tblgen ./llvm-tli-checker ./llvm-undname ./llvm-xray ./opt ./sancov ./sanstats ./split-file ./verify-uselistorder ; do 
    echo '1' > $INSTALL_PREFIX/llvm-libs/bin/$file
  done

)
