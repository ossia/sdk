#!/bin/bash -eux
export SDK_COMMON_ROOT=$PWD
source ./common.sh clang

source "$SDK_COMMON_ROOT/common/clone-qt.sh"

mkdir -p qt6-build-static
(
  cd qt6-build-static
  
  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt/configure \
  $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
  $(cat "$SDK_ROOT/common/qtfeatures.$QT_MODE") \
  -feature-vnc \
  -feature-library \
  -no-feature-libudev \
  -no-feature-glib \
  -no-feature-gtk3 \
  -system-zlib \
  -eglfs \
  -kms \
  -xcb \
  -vulkan \
  -linker lld \
  -platform linux-clang-libc++ \
  -prefix $INSTALL_PREFIX/qt6-static \
  -openssl-linked \
  -- \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX;$INSTALL_PREFIX/sysroot" \
  -DFREETYPE_DIR="$INSTALL_PREFIX/sysroot" \
  -Dharfbuzz_DIR="$INSTALL_PREFIX/sysroot" \
  -DHARFBUZZ_INCLUDE_DIRS="$INSTALL_PREFIX/sysroot/include" \
  -DHARFBUZZ_LIBRARIES="$INSTALL_PREFIX/sysroot/lib/libharfbuzz.a" \
  -DOPENSSL_ROOT_DIR="$INSTALL_PREFIX/openssl"
  
  cmake --build .
  cmake --build . --target install
)
