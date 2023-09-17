#!/bin/bash

source ./common.sh clang

PIPEWIRE_VERSION=0.3.59
MESON_VERSION=0.61.1
rm -rf pipewire
if [[ ! -d pipewire ]]; then
(
  wget -nv https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/$PIPEWIRE_VERSION/pipewire-$PIPEWIRE_VERSION.tar.gz
  tar xaf pipewire-$PIPEWIRE_VERSION.tar.gz
  rm -rf pipewire-$PIPEWIRE_VERSION.tar.gz
  #$GIT clone https://github.com/PipeWire/pipewire
)
fi

if [[ ! -d meson-$MESON_VERSION ]]; then
  wget https://github.com/mesonbuild/meson/releases/download/$MESON_VERSION/meson-$MESON_VERSION.tar.gz
  tar xaf meson-$MESON_VERSION.tar.gz
  rm -rf meson-$MESON_VERSION.tar.gz

  yum install system-devel systemd-udev
fi

export PATH=$PWD/meson-$MESON_VERSION:$PATH

(
cd pipewire-$PIPEWIRE_VERSION
rm -rf build

meson.py setup build  --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled 
meson.py configure build --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled 
meson.py compile -C build
meson.py install -C build
)
