#!/bin/bash

source ./common.sh

pacman -S mingw-w64-x86_64-zlib mingw-w64-x86_64-cmake wget diffutils yasm tar unzip

SDK_DIR=.