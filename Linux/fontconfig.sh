#!/bin/bash

source ./common.sh

if [[ ! -d fontconfig-2.14.2 ]]; then
(
  wget -nv https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.xz
  # $GIT clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git
  tar xaf fontconfig-2.14.2.tar.xz
)
fi

(

export LIBRARY_PATH=$INSTALL_PREFIX/freetype
export PKG_CONFIG_PATH=$INSTALL_PREFIX/freetype/lib64/pkgconfig:$INSTALL_PREFIX/harfbuzz/lib64/pkgconfig
meson_options=(
  -D default-hinting=slight
  -D default-sub-pixel-rendering=rgb
  -D doc-html=disabled
  -D doc-pdf=disabled
  -D doc-txt=disabled
  -D buildtype=$MESON_BUILD_TYPE 
  -D default_library=static 
  -D glib=disabled 
  -D gobject=disabled 
  -D icu=disabled 
  -D docs=disabled 
  -D prefix=$INSTALL_PREFIX/fontconfig
)
cd fontconfig-2.14.2
meson build "${meson_options[@]}"

cd build
ninja
ninja install
)

# 
# $CMAKE \
#   -S fontconfig-2.14.2 \
#   -B fontconfig-build \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DBUILD_SHARED_LIBS=OFF \
#   -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
#   -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/fontconfig
# 
# $CMAKE --build fontconfig-build --parallel
# $CMAKE --build fontconfig-build --target install/strip
# 