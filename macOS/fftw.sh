#!/bin/bash

source ./common.sh

export FFTW_VERSION=3.3.8
if [[ ! -f fftw-$FFTW_VERSION.tar.gz ]]; then
  wget -nv http://fftw.org/fftw-$FFTW_VERSION.tar.gz
  gtar xaf fftw-$FFTW_VERSION.tar.gz
fi

mkdir fftw-build
cd fftw-build

CFLAGS+=" -O3 -fomit-frame-pointer -fstrict-aliasing -ffast-math"
xcrun ../fftw-$FFTW_VERSION/configure   \
    --prefix=$INSTALL_PREFIX/fftw \
    --enable-threads              \
    --enable-fma                  \
    --enable-generic-simd128      \
    --enable-generic-simd256      \
    --enable-sse2                 \
    --enable-avx                  \
    --enable-avx-128-fma          \
    --enable-avx2                 \
    --enable-fma                  \
    --disable-fortran             \
    --with-gcc-arch=haswell       \
    CC="clang"                    \
    CXX="clang++"

xcrun make -j$NPROC
xcrun make install
