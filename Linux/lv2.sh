#!/bin/bash

source ./common.sh

$GIT clone --recursive -j12 https://github.com/lv2/lv2kit
(
export PATH=$PWD/meson-0.59.4:$PATH

cd lv2kit

rm -rf build
meson.py setup build
meson.py configure build --prefix=$INSTALL_PREFIX/lv2 -Ddocs=disabled -Dtests=disabled -Dtools=disabled
meson.py compile -C build
meson.py install -C build

)