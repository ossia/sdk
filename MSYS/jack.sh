#!/bin/bash

source ./common.sh
source ../common/clone-jack.sh

mkdir -p $INSTALL_PREFIX/jack/include
cp -rf jack2/common/jack $INSTALL_PREFIX/jack/include/
