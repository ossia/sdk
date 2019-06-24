#!/bin/bash -eux


cd /image
source /image/config.sh
apt-get -y install libxkbcommon-dev libxkbcommon-x11-dev
mkdir qt5-build
(
  cd qt5-build
  ../qt5/configure -release \
                   -opensource \
                   -confirm-license \
                   -nomake examples \
                   -nomake tests \
                   -no-compile-examples \
                   -no-qml-debug \
                   -no-mtdev \
                   -no-journald \
                   -no-syslog \
                   -no-gif \
                   -qt-libpng \
                   -qt-libjpeg \
                   -qt-freetype \
                   -qt-harfbuzz \
                   -openssl \
                   -qt-pcre \
                   -no-glib \
                   -no-cups \
                   -no-iconv \
                   -no-tslib \
                   -no-icu \
                   -no-pch \
                   -opengl es2 \
                   -no-system-proxies 

                   # ltcg causes harfbuzz failures
  make -j$NPROC
  make install -j$NPROC
)
