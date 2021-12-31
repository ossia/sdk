#!/bin/bash -eux

source ./common.sh
if [[ ! -d qt5 ]]; then
  $GIT clone https://invent.kde.org/qt/qt/qt5
  (
    cd qt5
    $GIT checkout kde/5.15
    $GIT submodule update --init --recursive $(cat "$SDK_ROOT/common/qtmodules")
    $GIT submodule update --init --recursive qtwayland
    $GIT config --global user.email "you@example.com"
    $GIT config --global user.name "Your Name"

    cd qtbase
    $GIT remote add jcelerier https://github.com/jcelerier/qtbase
    $GIT fetch jcelerier
    $GIT checkout jcelerier/kde/5.15

    sed -i 's/fuse-ld=gold/fuse-ld=lld/g' \
      mkspecs/common/gcc-base-unix.conf \
      mkspecs/features/qt_configure.prf \
      configure.json
    sed -i 's/-fvisibility=hidden/-fvisibility=default/g' mkspecs/common/gcc-base.conf
    sed -i 's/-fvisibility-inlines-hidden/ /g' mkspecs/common/gcc-base.conf
    sed -i "s/-O3/$CFLAGS/" mkspecs/common/gcc-base.conf
    sed -i "s/-O2/$CFLAGS/" mkspecs/common/gcc-base.conf
  )
fi
