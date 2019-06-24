#!/bin/bash -eux

cd /image
NPROC=$(nproc)

(
# https://www.mail-archive.com/gcc-bugs@gcc.gnu.org/msg550065.html
sed -i '540d' gcc-9.1.0/gcc/system.h
sed -i '496d' gcc-9.1.0/gcc/system.h
sed -i '112d' gcc-9.1.0/include/libiberty.h
)
mkdir gcc-build
(
  cd gcc-build
  # export CFLAGS="-O3 -march=armv7-a -g0"
  # export CXXFLAGS="-O3 -march=armv7-a -g0"
  ../combined/configure \
        --enable-languages=c,c++,lto \
        --enable-gold \
        --enable-plugins \
        --enable-plugin \
        --disable-multilib \
        --disable-nls \
        --enable-werror=no \
        --enable-threads \
        --enable-lto \
        --with-float=hard \
        --with-cpu=cortex-a7 \
        --with-fpu=neon-vfpv4 \
        --build=arm-linux-gnueabihf \
        --host=arm-linux-gnueabihf \
        --disable-bootstrap \
        --enable-stage1-checking=release \
        --with-sysroot=/ \
        --with-default-libstdcxx-abi=new \
        --disable-libitm \
        --disable-libquadmath \
        --enable-multiarch --disable-sjlj-exceptions \
        --enable-gnu-unique-object \
        --without-included-gettext \
        --with-arch-directory=arm \
        --program-suffix=-9 --program-prefix=arm-linux-gnueabihf- \
        --target=arm-linux-gnueabihf 
  # make BOOT_CFLAGS="-O3 -march=armv7-a -g0" -j$NPROC
  # make profiledbootstrap -j$NPROC -k -i
  # make profiledbootstrap -j$NPROC -k -i
  # make profiledbootstrap -j1
  make -j$NPROC
  make install-strip
)

rm -rf gcc-build
