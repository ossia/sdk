#!/bin/bash -eux

source ./common.sh
if [[ ! -d qt5 ]]; then
  git clone https://invent.kde.org/qt/qt/qt5
  (
    cd qt5
    git checkout kde/5.15
    git submodule update --init --recursive $(cat "$SDK_ROOT/common/qtmodules")
    git submodule update --init --recursive qtwayland
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

    cd qtbase

    git remote add jcelerier https://github.com/jcelerier/qtbase
    git fetch jcelerier
    git checkout jcelerier/kde/5.15

    cp -R mkspecs/linux-arm-gnueabi-g++ mkspecs/linux-arm-gnueabihf-g++
    sed -i -e "s/arm-linux-gnueabi-/$CROSS_TOOLS_PREFIX/g" mkspecs/linux-arm-gnueabihf-g++/qmake.conf

    sed -i "14s/$/ $CFLAGS/" mkspecs/linux-arm-gnueabihf-g++/qmake.conf
    sed -i "15s/$/ $CXXFLAGS/" mkspecs/linux-arm-gnueabihf-g++/qmake.conf

    sed -i "s/-O3/$CFLAGS/" mkspecs/common/gcc-base.conf
    sed -i "s/-O2/$CFLAGS/" mkspecs/common/gcc-base.conf
  )
fi
