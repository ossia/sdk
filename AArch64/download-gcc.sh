#!/bin/bash -eux

source common.sh

mkdir -p $SDK_INSTALL_ROOT
cd $SDK_INSTALL_ROOT
wget https://github.com/tttapa/docker-arm-cross-toolchain/releases/download/0.0.9/$CROSS_COMPILER_ARCHIVE
tar xaf $CROSS_COMPILER_ARCHIVE
mv x-tools/* .
rm -rf x-tools *.tar.*