#!/bin/bash -eux

cd /image
source /image/config.sh
wget https://cmake.org/files/v3.19/cmake-3.19.3.tar.gz
tar xaf cmake-*
rm cmake-*.tar.gz
cd cmake-*

./bootstrap && make -j$(nproc) && make install
