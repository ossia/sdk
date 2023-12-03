set(CMAKE_VERBOSE_MAKEFILE ON)
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_SYSTEM_PROCESSOR aarch64)

set(gcc_dir /opt/ossia-sdk-rpi-aarch64/aarch64-rpi3-linux-gnu)
set(gcc_resdir ${gcc_dir}/lib/gcc/aarch64-rpi3-linux-gnu/12.2.0/include)
set(gcc_cccdir ${gcc_dir}/aarch64-rpi3-linux-gnu/include/c++/12.2.0/aarch64-rpi3-linux-gnu)
set(gcc_cppdir ${gcc_dir}/aarch64-rpi3-linux-gnu/include/c++/12.2.0)
set(gcc_incdir ${gcc_dir}/aarch64-rpi3-linux-gnu/sysroot/usr/include)
set(gcc_stdlib ${gcc_dir}/aarch64-rpi3-linux-gnu/sysroot/lib)
set(tools /opt/ossia-sdk-rpi-aarch64/llvm)
set(rootfs_dir /opt/ossia-sdk-rpi-aarch64/pi/sysroot)
set(rpi_incdir ${rootfs_dir}/usr/include)
set(clang_resdir /opt/ossia-sdk-rpi-aarch64/llvm/lib/clang/14.0.6)

set(CMAKE_C_COMPILER ${tools}/bin/clang)
set(CMAKE_CXX_COMPILER ${tools}/bin/clang++)

set(CMAKE_C_FLAGS_INIT "-target aarch64-linux-gnu -nostdinc -resource-dir ${clang_resdir} ")
set(CMAKE_CXX_FLAGS_INIT "-target aarch64-linux-gnu -nostdinc -resource-dir ${clang_resdir} ")

include_directories(SYSTEM "${gcc_cccdir}")
include_directories(SYSTEM "${gcc_cppdir}")
include_directories(SYSTEM "${gcc_incdir}")
include_directories(SYSTEM "${clang_resdir}/include")
include_directories(SYSTEM "${gcc_resdir}")
include_directories(SYSTEM "${rootfs_dir}/usr/include/aarch64-linux-gnu")
include_directories(SYSTEM "${rpi_incdir}")

set(stdlibs " -nostdlib++ -L${gcc_stdlib} -L${rootfs_dir}/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,${rootfs_dir}/usr/lib/aarch64-linux-gnu ${gcc_stdlib}/libstdc++.a  ${gcc_stdlib}/libatomic.a -Wl,--sysroot=/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr ")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${stdlibs}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${stdlibs}")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${stdlibs}")

SET(CMAKE_SYSROOT ${rootfs_dir})

SET(CMAKE_FIND_ROOT_PATH ${rootfs_dir})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET (CMAKE_C_COMPILER_WORKS 1)
SET (CMAKE_CXX_COMPILER_WORKS 1)
