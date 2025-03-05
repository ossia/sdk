#!/bin/bash -eu

source ./common.sh

brew update
brew upgrade

brew install cmake ninja boost gnu-tar gnu-sed yasm subversion

SDK_DIR=.


