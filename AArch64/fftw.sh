#!/bin/bash

source ./common.sh clang
source ./common/clone-fftw.sh

mkdir -p fftw-build
cd fftw-build

CFLAGS+=" -O3 -fstrict-aliasing -ffast-math -fno-finite-math-only "
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
