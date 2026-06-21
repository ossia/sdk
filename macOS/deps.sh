#!/bin/bash -eu

source ./common.sh

brew update
brew upgrade

brew install cmake ninja boost gnu-tar gnu-sed yasm nasm subversion meson pkg-config ccache

SDK_DIR=.


