#!/bin/bash

source scl_source enable gcc-toolset-14

cd /image
cp ./CentOS/common.release.sh ./common.sh
exec ./build-all.sh
