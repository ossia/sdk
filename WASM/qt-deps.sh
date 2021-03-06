#!/bin/bash -eux

source ./common.sh
if [[ ! -d qt5 ]]; then
  git clone https://code.qt.io/qt/qt5.git
  (
    cd qt5
    git checkout 5.15
    git submodule update --init --recursive $(cat "$SDK_ROOT/common/qtmodules")
  )
fi
