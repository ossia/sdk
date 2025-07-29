#!/bin/bash -eux

export NPROC=$(nproc)
export INSTALL_PREFIX=/opt/ossia-sdk-$CPU_ARCH
export INSTALL_PREFIX_CMAKE=/opt/ossia-sdk-$CPU_ARCH
export SDK_ROOT=$PWD
if [[ "$CPU_ARCH" == 'aarch64' ]]; then
  export ARCH_VARNAME=AARCH64
  export ARCH=aarch64
  export GCC_ARCH="armv8-a+crc"
  export GCC_CPU="cortex-a53"
  export LLVM_ARCH=AArch64
  export ARCHFLAGS="-march=armv8-a+crc -mtune=cortex-a76"
else
  export ARCH_VARNAME=X86_64
  export ARCH=x86_64 # for openssl
  export GCC_ARCH=x86-64-v3 # for fftw
  export GCC_CPU=x86-64-v3
  export LLVM_ARCH=X86
  export ARCHFLAGS="-march=x86-64-v3"
fi
export CFLAGS="-DNDEBUG -O3 $ARCHFLAGS -fno-plt -fno-semantic-interposition -fno-stack-protector -pthread -fPIC " # -march=ivybridge -mtune=haswell"
export CXXFLAGS="$CFLAGS  -fnew-infallible" # -march=ivybridge -mtune=haswell"

export LD_LIBRARY_PATH=
if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH
  export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib
else
  export CC=clang
  export CXX=clang++
fi

export PATH=$SDK_ROOT/cmake/bin:$PATH
export GIT=/usr/bin/git
export CMAKE=$SDK_ROOT/cmake/bin/cmake
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-git218/root/usr/lib:/opt/rh/httpd24/root/usr/lib64

export CMAKE_BUILD_TYPE=Release
export MESON_BUILD_TYPE=release
export QT_MODE="release"
export LLVM_ADDITIONAL_FLAGS=" "

export MESON_COMMON_FLAGS=(
  -Dbuildtype=$MESON_BUILD_TYPE
  -Ddefault_library=static
  -Dglib=disabled
  -Dgobject=disabled
  -Dicu=disabled
  -Ddocs=disabled
  -Dtests=disabled
)
export CMAKE_COMMON_FLAGS=(
  -GNinja
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
)

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib64/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH:/usr/lib64/pkgconfig"
