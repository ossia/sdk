set(CMAKE_VERBOSE_MAKEFILE ON)
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_SYSTEM_PROCESSOR armhf)

set(tools /opt/ossia-sdk-rpi/armv8-rpi3-linux-gnueabihf)
set(rootfs_dir /opt/ossia-sdk-rpi/pi/sysroot)

set(CMAKE_C_COMPILER ${tools}/bin/armv8-rpi3-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/armv8-rpi3-linux-gnueabihf-g++)

include_directories("${rootfs_dir}/usr/include/arm-linux-gnueabihf")

set(CMAKE_SHARED_LINKER_FLAGS_INIT " -L${rootfs_dir}/usr/lib/arm-linux-gnueabihf -Wl,-rpath-link,${rootfs_dir}/usr/lib/arm-linux-gnueabihf -static-libgcc -static-libstdc++")
set(CMAKE_MODULE_LINKER_FLAGS_INIT " -L${rootfs_dir}/usr/lib/arm-linux-gnueabihf -Wl,-rpath-link,${rootfs_dir}/usr/lib/arm-linux-gnueabihf -static-libgcc -static-libstdc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT " -L${rootfs_dir}/usr/lib/arm-linux-gnueabihf -Wl,-rpath-link,${rootfs_dir}/usr/lib/arm-linux-gnueabihf -static-libgcc -static-libstdc++")

SET(CMAKE_SYSROOT ${rootfs_dir})

SET(CMAKE_FIND_ROOT_PATH ${rootfs_dir})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET (CMAKE_C_COMPILER_WORKS 1)
SET (CMAKE_CXX_COMPILER_WORKS 1)
