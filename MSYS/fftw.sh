#!/bin/bash

source ./common.sh
../common/clone-fftw.sh

mkdir -p fftw-build
cd fftw-build

CFLAGS+=" -g -O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math"

# SIMD: generic-simd128/256 are portable; the rest are x86-only. On arm64 the
# default (double precision) build can't use --enable-neon (that needs single
# precision), so it relies on the generic SIMD kernels.
FFTW_SIMD=( --enable-generic-simd128 --enable-generic-simd256 )
if [[ "$TARGET_ARCH" != "arm64" ]]; then
  FFTW_SIMD+=( --enable-fma --enable-sse2 --enable-avx --enable-avx-128-fma --enable-avx2 )
fi

../fftw-$FFTW_VERSION/configure   \
    --prefix=$INSTALL_PREFIX/fftw \
    --enable-threads              \
    --with-combined-threads       \
    "${FFTW_SIMD[@]}"             \
    --disable-fortran             \
    --with-our-malloc16           \
    CC="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" \
    CXX="$CXX"

$MAKE -j$NPROC
$MAKE install
