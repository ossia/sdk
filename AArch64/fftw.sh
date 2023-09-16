#!/bin/bash

source ./common.sh

export FFTW_VERSION=3.3.10
if [[ ! -f fftw-$FFTW_VERSION.tar.gz ]]; then
  wget -nv http://fftw.org/fftw-$FFTW_VERSION.tar.gz
  tar xaf fftw-$FFTW_VERSION.tar.gz
fi

mkdir -p fftw-build
cd fftw-build

CFLAGS+=" -O3 -fstrict-aliasing -ffast-math"
../fftw-$FFTW_VERSION/configure   \
    --build=x86_64-pc-linux-gnu --host=$FFTW_CROSS \
    --enable-threads              \
    --enable-single               \
    --prefix=$INSTALL_PREFIX/fftw \
    --enable-perf-events          \
    --enable-neon                 \
    --disable-fortran             \
    ARM_CPU_TYPE=cortex-a72
    # \
#    --with-gcc-arch=haswell

make -j$NPROC
make install
