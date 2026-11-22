# The stable bzip2 release has a Makefile but no CMake project. Build its
# libbz2.a target with the SDK's normal compiler, cross toolchain and PIC flags.
cmake_minimum_required(VERSION 3.15)
project(bzip2 VERSION ${BZIP2_RELEASE} LANGUAGES C)
include(GNUInstallDirs)

add_library(bz2 STATIC)
foreach(file blocksort huffman crctable randtable compress decompress bzlib)
  target_sources(bz2 PRIVATE "${BZIP2_SOURCE_DIR}/${file}.c")
endforeach()
target_compile_definitions(bz2 PRIVATE _FILE_OFFSET_BITS=64)
install(TARGETS bz2 ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  # Existing SDK consumers can link with either -lbz2 or -lbz2_static.
  install(FILES "$<TARGET_FILE:bz2>" DESTINATION "${CMAKE_INSTALL_LIBDIR}" RENAME libbz2_static.a)
endif()
install(FILES "${BZIP2_SOURCE_DIR}/bzlib.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

# The previous SDK shipped bzip2.pc alongside libbz2.a on both platforms.
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/bzip2.pc"
"prefix=\${pcfiledir}/../..
libdir=\${prefix}/${CMAKE_INSTALL_LIBDIR}
includedir=\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}

Name: bzip2
Description: Lossless, block-sorting data compression
Version: ${PROJECT_VERSION}
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/bzip2.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
