#!/bin/bash

source ./common.sh

export FFTW_VERSION=3.3.10
if [[ ! -f fftw-$FFTW_VERSION.tar.gz ]]; then
  wget -nv http://fftw.org/fftw-$FFTW_VERSION.tar.gz
  tar xaf fftw-$FFTW_VERSION.tar.gz
fi

mkdir -p fftw-build
cd fftw-build

CFLAGS+=" -g -O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math"
../fftw-$FFTW_VERSION/configure   \
    --prefix=$INSTALL_PREFIX/fftw \
    --enable-threads              \
    --with-combined-threads       \
    --enable-fma                  \
    --enable-generic-simd128      \
    --enable-generic-simd256      \
    --enable-sse2                 \
    --enable-avx                  \
    --enable-avx-128-fma          \
    --enable-avx2                 \
    --disable-fortran             \
    --with-our-malloc16           \
    CC="clang"                    \
    CXX="clang++"

make -j$NPROC
make install
