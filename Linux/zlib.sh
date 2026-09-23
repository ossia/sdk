#!/bin/bash -eux

source ./common.sh clang
source ../common/clone-zlib.sh

(
  cmake -S zlib-ng -B zlib-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DZLIB_COMPAT=1 \
  -DBUILD_SHARED_LIBS=0 \
  -DZLIB_ENABLE_TESTS=0 \
  -DZLIBNG_ENABLE_TESTS=0 \
  -DWITH_GTEST=0 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build zlib-build --config "$CMAKE_BUILD_TYPE"
  cmake --build zlib-build --config "$CMAKE_BUILD_TYPE" --target "${CMAKE_INSTALL_TARGET:-install/strip}"
)

(
  cmake -S bzip2 -B bzip2-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DENABLE_EXAMPLES=0 \
  -DENABLE_TESTS=0 \
  -DENABLE_DOCS=0 \
  -DENABLE_APP=0 \
  -DBUILD_SHARED_LIBS=0 \
  -DENABLE_STATIC_LIB=1 \
  -DENABLE_SHARED_LIB=0 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build bzip2-build --config "$CMAKE_BUILD_TYPE"
  cmake --build bzip2-build --config "$CMAKE_BUILD_TYPE" --target "${CMAKE_INSTALL_TARGET:-install/strip}"
  
  
  cp "$INSTALL_PREFIX/sysroot/lib/libbz2_static.a"  "$INSTALL_PREFIX/sysroot/lib/libbz2.a" || true
  cp "$INSTALL_PREFIX/sysroot/lib64/libbz2_static.a"  "$INSTALL_PREFIX/sysroot/lib64/libbz2.a" || true
)

(
  cmake -S zstd/build/cmake -B zstd-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DZSTD_BUILD_PROGRAMS=0 \
  -DBUILD_SHARED_LIBS=0 \
  -DBUILD_TESTING=0 \
  -DZSTD_BUILD_SHARED=0 \
  -DZSTD_BUILD_STATIC=1 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build zstd-build --config "$CMAKE_BUILD_TYPE"
  cmake --build zstd-build --config "$CMAKE_BUILD_TYPE" --target "${CMAKE_INSTALL_TARGET:-install/strip}"
  
)

(
  cmake -S brotli -B brotli-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBROTLI_DISABLE_TESTS=1 \
  -DBUILD_SHARED_LIBS=0 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot" \
  -DSHARE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build brotli-build --config "$CMAKE_BUILD_TYPE"
  cmake --build brotli-build --config "$CMAKE_BUILD_TYPE" --target "${CMAKE_INSTALL_TARGET:-install/strip}"
  
)

(
  cmake -S xz -B xz-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBUILD_SHARED_LIBS=0 \
  -DBUILD_TESTING=0 \
  -DXZ_SANDBOX=no \
  -DCREATE_XZ_SYMLINKS=0 \
  -DCREATE_LZMA_SYMLINKS=0 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build xz-build --config "$CMAKE_BUILD_TYPE"
  cmake --build xz-build --config "$CMAKE_BUILD_TYPE" --target "${CMAKE_INSTALL_TARGET:-install/strip}"
  
)

(
  cmake -S snappy -B snappy-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBUILD_SHARED_LIBS=0 \
  -DSNAPPY_BUILD_TESTS=0 \
  -DSNAPPY_BUILD_BENCHMARKS=0 \
  -DSNAPPY_INSTALL=1 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build snappy-build --config "$CMAKE_BUILD_TYPE"
  cmake --build snappy-build --config "$CMAKE_BUILD_TYPE" --target "${CMAKE_INSTALL_TARGET:-install/strip}"
  
)

rm -rf $INSTALL_PREFIX_CMAKE/sysroot/bin
rm -rf $INSTALL_PREFIX_CMAKE/sysroot/man
