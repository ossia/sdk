#!/bin/bash -eux

source ./common.sh clang
source ../common/clone-fontconfig.sh

# expat: fontconfig's XML parser for the configuration files.
cmake \
  -S "expat-$EXPAT_VERSION" \
  -B expat-build \
  "${CMAKE_COMMON_FLAGS[@]}" \
  -DEXPAT_SHARED_LIBS=OFF \
  -DEXPAT_BUILD_TOOLS=OFF \
  -DEXPAT_BUILD_EXAMPLES=OFF \
  -DEXPAT_BUILD_TESTS=OFF \
  -DEXPAT_BUILD_DOCS=OFF \
  -DEXPAT_BUILD_FUZZERS=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX/sysroot"
cmake --build expat-build --parallel
cmake --build expat-build --target install/strip

# The library is embedded in an application that runs on arbitrary distros, so
# every path compiled into it is the conventional host one: it reads the host's
# /etc/fonts/fonts.conf (and conf.d), font directories and system caches,
# never anything under the SDK prefix. Additional font dirs are those the build
# image happens to have, hence "no".
# Only the "devel" install tag is installed: library, headers and .pc. The
# "runtime" one would write fonts.conf and conf.d into the image's /etc.
(
  cd "fontconfig-$FONTCONFIG_VERSION"
  rm -rf build
  python3 "../meson-$FONTCONFIG_MESON_VERSION/meson.py" setup build \
    -Dbuildtype=$MESON_BUILD_TYPE \
    -Ddefault_library=static \
    -Dprefix="$INSTALL_PREFIX/sysroot" \
    -Dsysconfdir=/etc \
    -Dlocalstatedir=/var \
    -Dtemplate-dir=/usr/share/fontconfig/conf.avail \
    -Dxml-dir=/usr/share/xml/fontconfig \
    -Dadditional-fonts-dirs=no \
    -Dxml-backend=expat \
    -Dfontations=disabled \
    -Diconv=disabled \
    -Dnls=disabled \
    -Ddoc=disabled \
    -Dtests=disabled \
    -Dtools=disabled \
    -Dcache-build=disabled \
    -Dwrap_mode=nofallback
  python3 "../meson-$FONTCONFIG_MESON_VERSION/meson.py" compile -C build
  python3 "../meson-$FONTCONFIG_MESON_VERSION/meson.py" install -C build --tags devel
)
