#!/bin/bash -eux

source ./common.sh
if [[ ! -d qt6 ]]; then
  git clone https://code.qt.io/qt/qt5.git -b 6.5 qt6
  (
    cd qt6
    git submodule update --init --recursive $(cat "$SDK_ROOT/common/qtmodules") qtshadertools qtscxml
  )
fi
