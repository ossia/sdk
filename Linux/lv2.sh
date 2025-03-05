#!/bin/bash -eu

source ./common.sh clang
source ../common/clone-lv2.sh

(

cd lv2kit

rm -rf build
meson setup build  --prefix=$INSTALL_PREFIX/lv2 -Ddocs=disabled -Dtests=disabled -Dtools=disabled -Ddefault_library=static --wrap-mode=forcefallback
meson configure build --prefix=$INSTALL_PREFIX/lv2 -Ddocs=disabled -Dtests=disabled -Dtools=disabled -Ddefault_library=static --wrap-mode=forcefallback
meson compile -C build
meson install -C build
)