#!/bin/bash -eux

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh

source "$SDK_COMMON_ROOT/common/clone-qt.sh"


# disabled since we can't seem to make custom libc++ not crash...
# echo 'QMAKE_LFLAGS+= -L/opt/score-sdk-osx/llvm/lib -lc++ -lc++abi -Wl,-rpath,/opt/score-sdk-osx/llvm/lib' >> qt5/qtbase/mkspecs/common/clang-mac.conf

mkdir -p qt6-build-static
(
  cd qt6-build-static
  ../qt/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static \
                   -system-zlib \
                   -system-freetype \
                   -system-harfbuzz \
                   -prefix $INSTALL_PREFIX/qt6-static \
                   -c++std c++20 \
                   -DYYDEBUG=0 \
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
