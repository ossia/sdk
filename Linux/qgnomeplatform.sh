#!/bin/bash -eux
source ./common.sh

exit 0

(
  $GIT clone https://github.com/FedoraQt/QGnomePlatform
  cd QGnomePlatform
  mkdir build
  cd build
  cmake .. \
    -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX/qt5-static/ \
    -DCMAKE_BUILD_TYPE=Release
  make -j$NPROC
  make install -j$NPROC
)



