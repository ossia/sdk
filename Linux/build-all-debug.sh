#!/bin/bash -eux

source scl_source enable gcc-toolset-14

cd /image
cp ./CentOS/common.debug.sh ./common.sh
./build-all.sh || exit $?

source ./common.sh
cat > "$INSTALL_PREFIX/ossia-sdk-debug-toolchain.cmake" <<EOF
set(CMAKE_C_COMPILER "$INSTALL_PREFIX/llvm/bin/clang" CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER "$INSTALL_PREFIX/llvm/bin/clang++" CACHE FILEPATH "")
set(CMAKE_BUILD_TYPE Debug CACHE STRING "")
set(CMAKE_C_FLAGS_INIT "$CFLAGS")
set(CMAKE_CXX_FLAGS_INIT "$CXXFLAGS")
set(CMAKE_EXE_LINKER_FLAGS_INIT "$SANITIZER_LINK_FLAGS")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "$SANITIZER_LINK_FLAGS")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "$SANITIZER_LINK_FLAGS")
set(OSSIA_SDK "$INSTALL_PREFIX" CACHE PATH "")
EOF
