#!/bin/bash -eux

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh
source ../common/clone-qt.sh

# disabled since we can't seem to make custom libc++ not crash...
# echo 'QMAKE_LFLAGS+= -L/opt/score-sdk-osx/llvm/lib -lc++ -lc++abi -Wl,-rpath,/opt/score-sdk-osx/llvm/lib' >> qt5/qtbase/mkspecs/common/clang-mac.conf

mkdir -p qt6-build-asan
(
  cd qt6-build-asan
  ../qt/configure $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
                   -static -developer-build -debug \
                   -no-feature-vnc \
                   -system-zlib \
                   -system-freetype \
                   -system-harfbuzz \
                   -no-feature-cxx17_filesystem -no-warnings-are-errors \
                   -- \
                   -DCMAKE_C_FLAGS="$CFLAGS -O -fsanitize=address -fsanitize=undefined -g3 " \
                   -DCMAKE_CXX_FLAGS="$CXXFLAGS -O -fsanitize=address -fsanitize=undefined -g3 " \
                   -DCMAKE_SHARED_LINKER_FLAGS="-fsanitize=address -fsanitize=undefined " \
                   -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address -fsanitize=undefined " \
                   -DCMAKE_MODULE_LINKER_FLAGS="-fsanitize=address -fsanitize=undefined " \
                   -DCMAKE_CXX_STANDARD=20 \
                   -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
                   -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
                   -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
                   -Dharfbuzz_DIR=$INSTALL_PREFIX/harfbuzz \
                   -DHARFBUZZ_INCLUDE_DIRS=$INSTALL_PREFIX/harfbuzz/include \
                   -DHARFBUZZ_LIBRARIES=$INSTALL_PREFIX/harfbuzz/lib/libharfbuzz.a \
                    $CMAKE_ADDITIONAL_FLAGS

  
  cmake --build .
)
