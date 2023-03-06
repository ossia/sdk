#!/bin/bash -eux
export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

source "$SDK_COMMON_ROOT/common/clone-qt.sh"

mkdir -p qt6-build-static
(
  cd qt6-build-static

  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt/configure \
    $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
    $(cat "$SDK_ROOT/common/qtfeatures.$QT_MODE") \
                   -feature-vnc \
                   -system-zlib \
                   -linker lld \
                   -no-feature-wayland-server \
                   -platform linux-clang-libc++ \
                   -prefix $INSTALL_PREFIX/qt6-static \
                   -- \
                   -DCMAKE_C_FLAGS="$CFLAGS" \
                   -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
                   -DCMAKE_CXX_STANDARD=20 \
                   -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
                   -Dharfbuzz_DIR=$INSTALL_PREFIX/harfbuzz \
                   -DHARFBUZZ_INCLUDE_DIRS=$INSTALL_PREFIX/harfbuzz/include \
                   -DHARFBUZZ_LIBRARIES=$INSTALL_PREFIX/harfbuzz/lib/libharfbuzz.a

  cmake --build .
  cmake --build . --target install
)
