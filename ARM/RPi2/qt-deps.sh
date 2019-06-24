#!/bin/bash -eux

cd /image

git clone https://code.qt.io/qt/qt5.git

(
  cd qt5
  git checkout 5.13
  perl init-repository --module-subset=qtbase,qtimageformats,qtsvg,qtwebsockets,qtdeclarative,qtserialport,qtquickcontrols2,qtgraphicaleffects
)
