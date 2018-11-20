#!/bin/bash

wget -nv http://www.portaudio.com/archives/pa_snapshot.tgz
tar xaf pa_snapshot.tgz

cd portaudio/build

cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=/opt/score-sdk/portaudio

make -j8
make install