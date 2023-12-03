set(CMAKE_VERBOSE_MAKEFILE ON)
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_SYSTEM_PROCESSOR aarch64)

set(tools /opt/ossia-sdk-rpi-aarch64/aarch64-rpi3-linux-gnu)
set(rootfs_dir /opt/ossia-sdk-rpi-aarch64/pi/sysroot)

set(CMAKE_C_COMPILER ${tools}/bin/aarch64-rpi3-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/aarch64-rpi3-linux-gnu-g++)

include_directories("${rootfs_dir}/usr/include/aarch64-linux-gnu")

set(CMAKE_SHARED_LINKER_FLAGS_INIT " -L${rootfs_dir}/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,${rootfs_dir}/usr/lib/aarch64-linux-gnu -static-libgcc -static-libstdc++")
set(CMAKE_MODULE_LINKER_FLAGS_INIT " -L${rootfs_dir}/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,${rootfs_dir}/usr/lib/aarch64-linux-gnu -static-libgcc -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT " -L${rootfs_dir}/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,${rootfs_dir}/usr/lib/aarch64-linux-gnu -static-libgcc -static-libstdc++")

SET(CMAKE_SYSROOT ${rootfs_dir})

SET(CMAKE_FIND_ROOT_PATH ${rootfs_dir})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET (CMAKE_C_COMPILER_WORKS 1)
SET (CMAKE_CXX_COMPILER_WORKS 1)
