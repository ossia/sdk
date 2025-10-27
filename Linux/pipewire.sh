#!/bin/bash -eux

source ./common.sh clang
source ../common/clone-pipewire.sh

if [[ -f $INSTALL_PREFIX/pipewire/bin/pipewire ]]; then
  exit 0
fi
(
  cd pipewire-$PIPEWIRE_VERSION
  rm -rf build
  
  meson setup build  --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled  -Ddbus=disabled -Dflatpak=disabled
  meson configure build --prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]" -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled -Ddbus=disabled -Dflatpak=disabled
  meson compile -C build
  meson install -C build
)
