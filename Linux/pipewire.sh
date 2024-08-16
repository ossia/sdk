#!/bin/bash

source ./common.sh clang

PIPEWIRE_VERSION=0.3.59
rm -rf pipewire
if [[ ! -d pipewire ]]; then
(
  wget -nv https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/$PIPEWIRE_VERSION/pipewire-$PIPEWIRE_VERSION.tar.gz
  tar xaf pipewire-$PIPEWIRE_VERSION.tar.gz
  rm -rf pipewire-$PIPEWIRE_VERSION.tar.gz
  #$GIT clone https://github.com/PipeWire/pipewire
)
fi

yum install systemd-devel systemd-udev

(
cd pipewire-$PIPEWIRE_VERSION
rm -rf build

meson setup build  --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled  -Ddbus=disabled -Dflatpak=disabled
meson configure build --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled -Ddbus=disabled -Dflatpak=disabled
meson compile -C build
meson install -C build
)
