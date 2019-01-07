#!/bin/bash

source ./common.sh

brew update
brew upgrade

brew install cmake ninja boost gnu-tar gnu-sed yasm subversion

SDK_DIR=.
cd /usr/local/Cellar
#gtar caf "$SDK_DIR/homebrew-cache.txz" qt cmake ninja boost  


