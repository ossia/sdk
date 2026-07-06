#!/bin/bash -eux

source ./common.sh
# NB: the checkout dir is 'qt' to match qt.sh (../qt/configure). The Qt super-repo
# is qt5.git even for Qt 6.x; $QT_VERSION (common/versions.sh) selects the tag, so
# the WASM Qt tracks the same version as every other platform.
if [[ ! -d qt ]]; then
  git clone $SDK_CLONE_DEPTH https://code.qt.io/qt/qt5.git -b "$QT_VERSION" qt
  (
    cd qt
    git submodule update --init --recursive $SDK_CLONE_DEPTH $(cat "$SDK_ROOT/common/qtmodules")
  )
fi
