#!/bin/bash

wget -nv http://www.portaudio.com/archives/pa_snapshot.tgz
gtar xaf pa_snapshot.tgz

cd portaudio/build

cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DPA_BUILD_SHARED=Off \
 -DCMAKE_INSTALL_PREFIX=/opt/score-sdk/portaudio

make -j8
make install