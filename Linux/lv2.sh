#!/bin/bash

source ./common.sh

$GIT clone --recursive -j12 https://github.com/lv2/lv2kit
(
cd lv2kit
./waf configure --prefix=$INSTALL_PREFIX/lv2  --no-utils --no-bindings --no-plugins -j16
./waf
./waf install
)