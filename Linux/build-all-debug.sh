#!/bin/bash

source scl_source enable llvm-toolset

cd /image
cp ./CentOS/common.debug.sh ./common.sh
exec ./build-all.sh
