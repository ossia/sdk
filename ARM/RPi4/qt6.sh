#!/bin/bash -eux
export ORIGPATH="$PATH"
source ./common.sh

mkdir -p qt6-build-host
(
  exit 0
  cd qt6-build-host
  unset CC
  unset CXX
  unset CFLAGS
  unset CXXFLAGS
  export PATH=$ORIGPATH

  cmake -GNinja \
     -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=$SDK_INSTALL_ROOT/qt6-host \
     ../qt6

  ninja
  ninja install/strip

)
     
mkdir -p qt6-build-static
(
  cd qt6-build-static
  cmake \
    -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN \
    -DBUILD_SHARED_LIBS=0 \
    -DCMAKE_BUILD_TYPE=Release \
    -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/qt6-static \
    -DQT_HOST_PATH=$SDK_INSTALL_ROOT/qt6-host \
    -DQT_FEATURE_system_libb2=0 \
    ../qt6
  
#  cmake --build . --parallel
#  cmake --build . --target install/strip

  exit 0

  export SYSROOT_LOCATION=$SDK_INSTALL_ROOT/pi/sysroot

  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/lib
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/lib:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/libc/usr/lib:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/libc/lib:$LD_LIBRARY_PATH

  export LDFLAGS="-L$CROSS_COMPILER_LOCATION/lib/ -L$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/lib/"

  # FIXME needed for Qt to find things in the proper sysroot due to stupid multiarch bs
  export PKG_CONFIG_LIBDIR=/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/share/pkgconfig:/opt/ossia-sdk-rpi-aarch64/pi/sysroot/usr/lib/aarch64-rpi3-linux-gnu/pkgconfig




  ../qt6/configure $(cat "$SDK_ROOT/common/qtfeatures") \
                   -release -opengl es2 -eglfs -kms \
                   -device $QT_CROSS_DEVICE \
                   -pkg-config \
                   -device-option CROSS_COMPILE=$CCPREFIX \
                   -sysroot $SYSROOT_LOCATION \
                   -prefix $INSTALL_PREFIX/qt5-static \
                   -extprefix $INSTALL_PREFIX/qt5-static \
                   -static \
                   -system-zlib \
                   -no-feature-wayland-server \
                   -no-feature-zstd \
                   -v -recheck \
                   -L$CROSS_COMPILER_LOCATION/lib/ -L$CROSS_COMPILER_LOCATION/$DEBIAN_MULTIARCH_FOLDER/lib/ \
                   -L$SYSROOT_LOCATION/usr/lib/$DEBIAN_MULTIARCH_FOLDER -I$SYSROOT_LOCATION/usr/include/$DEBIAN_MULTIARCH_FOLDER

  make -j$NPROC
  make install -j$NPROC
)
