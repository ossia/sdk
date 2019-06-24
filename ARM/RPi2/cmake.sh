#!/bin/bash -eux

cd /image
source /image/config.sh
wget https://cmake.org/files/v3.15/cmake-3.15.0-rc2.tar.gz
tar xaf cmake-3.15.0-rc2.tar.gz
cd cmake-3.15.0-rc2
./bootstrap && make -j$(nproc) && make install
