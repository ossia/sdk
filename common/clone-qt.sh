#!/bin/bash

source ../common/versions.sh

if [[ ! -d qt ]]; then
git clone https://github.com/qt/qt5 qt -b $QT_VERSION

(
  cd qt
  git submodule update --init --recursive $(cat "$SDK_COMMON_ROOT/common/qtmodules")

  (
    cd qtbase
    git remote add jcelerier https://github.com/jcelerier/qtbase
    git fetch jcelerier
    git checkout jcelerier/$QT_VERSION-ossia
  )



  (
    cd qtdeclarative
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git fetch https://codereview.qt-project.org/qt/qtdeclarative refs/changes/68/464668/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtshadertools
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git fetch https://codereview.qt-project.org/qt/qtshadertools refs/changes/63/464663/2 && git cherry-pick FETCH_HEAD
  )
)
fi