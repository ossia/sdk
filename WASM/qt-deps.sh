#!/bin/bash -eux

source ./common.sh
# NB: the checkout dir is 'qt' to match qt.sh (../qt/configure). The Qt super-repo
# is qt5.git even for Qt 6.x; $QT_VERSION (common/versions.sh) selects the commit,
# so the WASM Qt tracks the same version as every other platform. It is a SHA, so
# fetch it directly: `clone -b` only takes a branch or tag name.
if [[ ! -d qt ]]; then
  git init -q qt
  (
    cd qt
    git remote add origin https://code.qt.io/qt/qt5.git
    git fetch $SDK_CLONE_DEPTH origin "$QT_VERSION"
    git checkout -q FETCH_HEAD
    git submodule update --init --recursive $SDK_CLONE_DEPTH $(cat "$SDK_ROOT/common/qtmodules")
  )
fi
