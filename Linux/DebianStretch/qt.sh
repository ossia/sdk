#!/bin/sh


apt-get install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev perl python libpcre2-dev libmtdev-dev libharfbuzz-dev libvulkan-dev libjpeg-dev libatspi2.0-dev libdbus-1-dev libdbus-c++-dev libsdl2-dev libproxy-dev libssl-dev
../qt5/configure -opensource -confirm-license -skip qtmultimedia -nomake examples -nomake tests -static -release -prefix /opt/qt5-static -c++std 1z -ltcg  -qt-doubleconversion
