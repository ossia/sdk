#!/bin/bash

brew update
brew upgrade

brew install qt5 cmake ninja boost gnu-tar

SDK_DIR=.
cd /usr/local/Cellar
gtar caf "$SDK_DIR/homebrew-cache.txz" qt cmake ninja boost  


