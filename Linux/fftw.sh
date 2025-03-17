#!/bin/bash -eu

source ./common.sh clang
source ./common/clone-fftw.sh

if [[ -f $INSTALL_PREFIX/fftw/include/fftw3.h ]]; then
  exit 0
fi
mkdir -p fftw-build
cd fftw-build

declare -a FFTW_AARCH64_FLAGS=(
  --build=aarch64-none-linux-gnu
  --host=aarch64-none-linux-gnu
  --enable-threads
  --enable-single
  --prefix=$INSTALL_PREFIX/fftw
  --enable-perf-events
  --enable-neon
  --disable-fortran
  ARM_CPU_TYPE=cortex-a72
)

declare -a FFTW_X86_64_FLAGS=(
  --enable-threads
  --prefix=$INSTALL_PREFIX/fftw
  --enable-fma
  --enable-generic-simd128
  --enable-generic-simd256
  --enable-sse2
  --enable-avx
  --enable-avx-128-fma
  --enable-avx2
  --enable-fma
  --disable-fortran
  --with-gcc-arch=$GCC_ARCH
)

declare -n FFTW_ARCH_FLAGS=FFTW_${ARCH_VARNAME}_FLAGS

CFLAGS+=" -O3 -fstrict-aliasing -ffast-math -fno-finite-math-only "

../fftw-$FFTW_VERSION/configure "${FFTW_ARCH_FLAGS[@]}"

make -j$NPROC
make install
