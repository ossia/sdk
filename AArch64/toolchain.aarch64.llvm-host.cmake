set(CMAKE_VERBOSE_MAKEFILE ON)
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_SYSTEM_PROCESSOR aarch64)

# clang++ -v foo.cpp 
# -stdlib=libc++ 
# --target=aarch64-linux-gnu 
# -fuse-ld=lld 
# --sysroot=/mnt/pi/ 
# -nostdinc++ 
# -isystem /mnt/pi/usr/lib/llvm-15/include/c++/v1 
# --rtlib=compiler-rt 
# -resource-dir /mnt/pi/usr/lib/llvm-15/lib/clang/15.0.7/


set(gcc_dir /opt/ossia-sdk-rpi-aarch64/aarch64-rpi3-linux-gnu)
set(gcc_resdir ${gcc_dir}/lib/gcc/aarch64-rpi3-linux-gnu/12.2.0/include)
set(gcc_cccdir ${gcc_dir}/aarch64-rpi3-linux-gnu/include/c++/12.2.0/aarch64-rpi3-linux-gnu)
set(gcc_cppdir ${gcc_dir}/aarch64-rpi3-linux-gnu/include/c++/12.2.0)
set(gcc_incdir ${gcc_dir}/aarch64-rpi3-linux-gnu/sysroot/usr/include)
set(gcc_stdlib ${gcc_dir}/aarch64-rpi3-linux-gnu/sysroot/lib)
set(tools /opt/ossia-sdk-rpi-aarch64/llvm)
set(rootfs_dir /opt/ossia-sdk-rpi-aarch64/pi/sysroot)
set(llvm_host_dir /opt/ossia-sdk-rpi-aarch64/pi/llvm-16)
set(llvm_target_dir /opt/ossia-sdk-rpi-aarch64/pi/llvm-16-aarch64)
set(rpi_incdir ${rootfs_dir}/usr/include)

set(CMAKE_C_COMPILER ${llvm_host_dir}/bin/clang)
set(CMAKE_CXX_COMPILER ${llvm_host_dir}/bin/clang++)

add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-O3>)
add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-g0>)
add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-mcpu=cortex-a72>)
add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:--target=aarch64-unknown-linux-gnu>)
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:--sysroot=${rootfs_dir}>")
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:-resource-dir;${llvm_target_dir}/lib/clang/16>")
add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-rtlib=compiler-rt>)
add_compile_options($<$<COMPILE_LANGUAGE:C,CXX>:-nostdinc>)
add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-nostdinc++>)
add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:SHELL:-Xclang -internal-isystem -Xclang  ${llvm_target_dir}/include/aarch64-unknown-linux-gnu/c++/v1>")
add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:SHELL:-Xclang -internal-isystem -Xclang  ${llvm_target_dir}/include/c++/v1>")
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:SHELL:-Xclang -internal-isystem -Xclang ${llvm_target_dir}/lib/clang/16/include>")
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:SHELL: -Xclang -internal-externc-isystem -Xclang ${rootfs_dir}/usr/include>")
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:SHELL: -Xclang -internal-externc-isystem -Xclang ${rootfs_dir}/usr/include/aarch64-linux-gnu>")

# include_directories(SYSTEM "${gcc_cccdir}")
# include_directories(SYSTEM "${gcc_cppdir}")
# include_directories(SYSTEM "${gcc_incdir}")
# include_directories(SYSTEM "${clang_resdir}/include")
# include_directories(SYSTEM "${gcc_resdir}")
# include_directories(SYSTEM "${rootfs_dir}/usr/include/aarch64-linux-gnu")
# include_directories(SYSTEM "${rpi_incdir}")

add_link_options($<$<COMPILE_LANGUAGE:C,CXX>:--target=aarch64-unknown-linux-gnu>)
add_link_options("$<$<COMPILE_LANGUAGE:C,CXX>:--sysroot=${rootfs_dir}>")
add_link_options("$<$<COMPILE_LANGUAGE:C,CXX>:-resource-dir;${llvm_target_dir}/lib/clang/16>")
add_link_options($<$<COMPILE_LANGUAGE:C,CXX>:-rtlib=compiler-rt>)
add_link_options($<$<COMPILE_LANGUAGE:C,CXX>:-fuse-ld=lld>)
add_link_options($<$<COMPILE_LANGUAGE:CXX>:-nostdlib++>)
add_link_options($<$<COMPILE_LANGUAGE:CXX>:${llvm_target_dir}/lib/aarch64-unknown-linux-gnu/libc++.a>)
add_link_options($<$<COMPILE_LANGUAGE:CXX>:${llvm_target_dir}/lib/aarch64-unknown-linux-gnu/libc++abi.a>)
add_link_options($<$<COMPILE_LANGUAGE:CXX>:${llvm_target_dir}/lib/aarch64-unknown-linux-gnu/libunwind.a>)


SET(CMAKE_SYSROOT ${rootfs_dir})

SET(CMAKE_FIND_ROOT_PATH ${rootfs_dir})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# SET (CMAKE_C_COMPILER_WORKS 1)
# SET (CMAKE_CXX_COMPILER_WORKS 1)

set(TARGET_SYSROOT ${rootfs_dir})

#set(ENV{PKG_CONFIG_PATH}  "${TARGET_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig")
set(ENV{PKG_CONFIG_PATH}  "${TARGET_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${TARGET_SYSROOT}/usr/share/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR} ${TARGET_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig:${TARGET_SYSROOT}/usr/lib/pkgconfig)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

set(XCB_PATH_VARIABLE ${TARGET_SYSROOT})

set(GL_INC_DIR ${TARGET_SYSROOT}/usr/include)
set(GL_LIB_DIR ${TARGET_SYSROOT}:${TARGET_SYSROOT}/usr/lib/aarch64-linux-gnu/:${TARGET_SYSROOT}/usr:${TARGET_SYSROOT}/usr/lib)

set(EGL_INCLUDE_DIR ${GL_INC_DIR})
set(EGL_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libEGL.so)

set(OPENGL_INCLUDE_DIR ${GL_INC_DIR})
set(OPENGL_opengl_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libOpenGL.so)

set(GLESv2_INCLUDE_DIR ${GL_INC_DIR})
set(GLIB_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libGLESv2.so)

set(GLESv2_INCLUDE_DIR ${GL_INC_DIR})
set(GLESv2_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libGLESv2.so)

set(gbm_INCLUDE_DIR ${GL_INC_DIR})
set(gbm_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libgbm.so)

set(Libdrm_INCLUDE_DIR ${GL_INC_DIR})
set(Libdrm_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libdrm.so)

set(XCB_XCB_INCLUDE_DIR ${GL_INC_DIR})
set(XCB_XCB_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/aarch64-linux-gnu/libxcb.so)

set(FREETYPE_INCLUDE_DIR ${TARGET_SYSROOT}/usr/include/freetype2)
set(FREETYPE_LIBRARY ${TARGET_SYSROOT}/usr/lib/aarch64-linux-gnu/libfreetype.so)

set(HARFBUZZ_INCLUDE_DIR ${TARGET_SYSROOT}/usr/include/harfbuzz)
set(HARFBUZZ_LIBRARY ${TARGET_SYSROOT}/usr/lib/aarch64-linux-gnu/libharfbuzz.so)

set(BOOST_ROOT /opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/include)
set(Boost_NO_SYSTEM_PATHS 1)
