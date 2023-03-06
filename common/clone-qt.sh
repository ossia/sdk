#!/bin/bash

if [[ ! -d qt ]]; then
git clone https://github.com/qt/qt5 qt -b 6.5

(
  cd qt
  git submodule update --init --recursive $(cat "$SDK_COMMON_ROOT/common/qtmodules")

  (
    cd qtbase
    git remote add jcelerier https://github.com/jcelerier/qtbase
    git fetch jcelerier
    git checkout jcelerier/6.5-ossia

    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/62/464662/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtdeclarative
    git fetch https://codereview.qt-project.org/qt/qtdeclarative refs/changes/68/464668/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtshadertools
    git fetch https://codereview.qt-project.org/qt/qtshadertools refs/changes/63/464663/2 && git cherry-pick FETCH_HEAD
  )
)
fi