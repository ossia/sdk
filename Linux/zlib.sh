#!/bin/bash -eux

source ./common.sh clang
source ../common/clone-zlib.sh

(
  cmake -S "$ZLIB_NG_SRC" -B "$ZLIB_NG_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DZLIB_COMPAT=1 \
  -DBUILD_SHARED_LIBS=0 \
  -DBUILD_TESTING=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build "$ZLIB_NG_SRC-build" --config Release --target install/strip
)

(
  cmake -S ../common/bzip2 -B "$BZIP2_VERSION-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBZIP2_SOURCE_DIR="$PWD/$BZIP2_VERSION" \
  -DBZIP2_RELEASE="${BZIP2_VERSION#bzip2-}" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build "$BZIP2_VERSION-build" --config Release --target install/strip

  if [[ -d "$INSTALL_PREFIX/sysroot/lib64" && ! -e "$INSTALL_PREFIX/sysroot/lib" ]]; then
    ln -s lib64 "$INSTALL_PREFIX/sysroot/lib"
  fi
)

(
  cmake -S "$ZSTD_SRC/build/cmake" -B "$ZSTD_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DZSTD_BUILD_PROGRAMS=0 \
  -DBUILD_SHARED_LIBS=0 \
  -DBUILD_TESTING=0 \
  -DZSTD_BUILD_SHARED=0 \
  -DZSTD_BUILD_STATIC=1 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build "$ZSTD_SRC-build" --config Release --target install/strip
  
)

(
  cmake -S "$BROTLI_SRC" -B "$BROTLI_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBROTLI_BUILD_TOOLS=OFF \
  -DBUILD_SHARED_LIBS=0 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build "$BROTLI_SRC-build" --config Release --target install/strip
  
)

(
  cmake -S "$XZ_SRC" -B "$XZ_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBUILD_SHARED_LIBS=0 \
  -DBUILD_TESTING=0 \
  -DXZ_TOOL_SYMLINKS=OFF \
  -DXZ_TOOL_SYMLINKS_LZMA=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build "$XZ_SRC-build" --config Release --target install/strip
  
)

(
  # Upstream adds -Werror for Clang. As in the old SDK fork, keep dependency
  # warnings visible without making them fatal as the SDK compiler advances.
  # Hidden inline helpers can be inlined under GCC -fPIC too, without making
  # its public, non-inline C/C++ API hidden when linked into a shared object.
  cmake -S "$SNAPPY_SRC" -B "$SNAPPY_SRC-build" \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DBUILD_SHARED_LIBS=0 \
  -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
  -DCMAKE_CXX_FLAGS_RELEASE_INIT=-Wno-error \
  -DCMAKE_CXX_FLAGS_DEBUG_INIT=-Wno-error \
  -DSNAPPY_BUILD_TESTS=0 \
  -DSNAPPY_BUILD_BENCHMARKS=0 \
  -DSNAPPY_INSTALL=1 \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_CMAKE/sysroot"
  
  cmake --build "$SNAPPY_SRC-build" --config Release --target install/strip
  
)

rm -rf $INSTALL_PREFIX_CMAKE/sysroot/bin
rm -rf $INSTALL_PREFIX_CMAKE/sysroot/man
