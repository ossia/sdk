#!/bin/bash -eux

source ./common.sh
if [[ ! -d qt5 ]]; then
  git clone https://code.qt.io/qt/qt5.git
  (
    cd qt5
    git checkout 5.15
    git submodule update --init --recursive $(cat "$SDK_ROOT/common/qtmodules")
    git submodule update --init --recursive qtwayland
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

    cd qtbase

    cp -R mkspecs/linux-arm-gnueabi-g++ mkspecs/linux-arm-gnueabihf-g++
    sed -i -e 's/arm-linux-gnueabi-/arm-linux-gnueabihf-/g' mkspecs/linux-arm-gnueabihf-g++/qmake.conf

    sed -i "14s/$/ $CFLAGS/" mkspecs/linux-arm-gnueabihf-g++/qmake.conf
    sed -i "15s/$/ $CXXFLAGS/" mkspecs/linux-arm-gnueabihf-g++/qmake.conf

  )
fi
