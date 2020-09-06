#!/bin/bash

source ./common.sh

choco install activeperl
pacman -S mingw-w64-x86_64-make mingw-w64-x86_64-zlib mingw-w64-x86_64-python mingw-w64-x86_64-cmake wget diffutils yasm tar unzip

SDK_DIR=.