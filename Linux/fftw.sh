#!/bin/bash -eu

source ./common.sh clang
source ./common/clone-fftw.sh

mkdir -p fftw-build
cd fftw-build

CFLAGS+=" -O3 -fstrict-aliasing -ffast-math -fno-finite-math-only "
../fftw-$FFTW_VERSION/configure   \
    --enable-threads              \
    --prefix=$INSTALL_PREFIX/fftw \
    --enable-fma                  \
    --enable-generic-simd128      \
    --enable-generic-simd256      \
    --enable-sse2                 \
    --enable-avx                  \
    --enable-avx-128-fma          \
    --enable-avx2                 \
    --enable-fma                  \
    --disable-fortran             \
    --with-gcc-arch=x86-64-v3

make -j$NPROC
make install
