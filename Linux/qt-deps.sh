#!/bin/bash -eux

source ./common.sh
$GIT clone https://code.qt.io/qt/qt5.git

export QT_BRANCH=5.14
(
  cd qt5
  $GIT checkout $QT_BRANCH
  $GIT submodule update --init --recursive qtbase qtdeclarative qtquickcontrols2 qtserialport qtimageformats qtgraphicaleffects qtsvg qtwebsockets
  $GIT config --global user.email "you@example.com"
  $GIT config --global user.name "Your Name"

  (
  cd qtbase
  $GIT checkout $QT_BRANCH
  sed -i 's/fuse-ld=gold/fuse-ld=lld/g' \
    mkspecs/common/gcc-base-unix.conf \
    mkspecs/features/qt_configure.prf \
    configure.json   
  )
  (cd qtdeclarative ; $GIT checkout $QT_BRANCH)
  (cd qtquickcontrols2 ; $GIT checkout $QT_BRANCH)
  (cd qtserialport ; $GIT checkout $QT_BRANCH)
  (cd qtimageformats ; $GIT checkout $QT_BRANCH)
  (cd qtgraphicaleffects ; $GIT checkout $QT_BRANCH)
  (cd qtsvg ; $GIT checkout $QT_BRANCH)
  (cd qtwebsockets ; $GIT checkout $QT_BRANCH)
)
