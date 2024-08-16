#!/bin/bash

source scl_source enable llvm-toolset

cd /image
cp ./CentOS/common.release.sh ./common.sh
exec ./build-all.sh
