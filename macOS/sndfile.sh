#!/bin/bash

source ./common.sh

#git clone  https://github.com/jcelerier/libsndfile


mkdir sndfile-build
cd sndfile-build

xcrun cmake \
 -GNinja \
 -DBUILD_PROGRAMS=0 \
 -DBUILD_EXAMPLES=0 \
 -DENABLE_PACKAGE_CONFIG=0 \
 -DINSTALL_PKGCONFIG_MODULE=0 \
 -DENABLE_EXPERIMENTAL=0 \
 -DBUILD_REGTEST=0 \
 -DBUILD_TESTING=0 \
 -DBUILD_SHARED_LIBS=0 \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_OSX_SYSROOT=$MACOS_SYSROOT \
 -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_VERSION \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/sndfile \
 ../libsndfile

xcrun cmake --build . --parallel
xcrun cmake --build . --parallel --target install/strip

