set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_SYSROOT /home/jcelerier/x-tools/arm-linaro-linux-gnueabihf/arm-linaro-linux-gnueabihf/sysroot)
set(tools /home/jcelerier/x-tools/arm-linaro-linux-gnueabihf/bin)
set(CMAKE_C_COMPILER ${tools}/arm-linaro-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${tools}/arm-linaro-linux-gnueabihf-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
