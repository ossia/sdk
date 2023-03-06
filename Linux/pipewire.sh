#!/bin/bash

source ./common.sh

if [[ ! -d pipewire ]]; then
(
  $GIT clone https://github.com/PipeWire/pipewire
)
fi

if [[ ! -d meson-0.59.4 ]]; then
  wget https://github.com/mesonbuild/meson/releases/download/0.59.4/meson-0.59.4.tar.gz
  tar xaf meson-0.59.4.tar.gz
  rm -rf meson-0.59.4.tar.gz
  export PATH=$PWD/meson-0.59.4:$PATH

  yum install system-devel
fi

(
cd pipewire
rm -rf build

meson.py setup build  --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled 
meson.py configure build --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled 
meson.py compile -C build
meson.py install -C build
)