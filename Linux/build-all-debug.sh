#!/bin/bash

source scl_source enable gcc-toolset-11

cd /image
cp ./CentOS/common.debug.sh ./common.sh
./build-all.sh