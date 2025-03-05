#!/bin/bash -eu

source ./common.sh

git clone https://github.com/jackaudio/jack2
mkdir -p $INSTALL_PREFIX/jack/include
cp -rf jack2/common/jack $INSTALL_PREFIX/jack/include/
