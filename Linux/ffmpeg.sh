#!/bin/bash

wget -nv https://ffmpeg.org/releases/ffmpeg-4.1.tar.xz
tar -xaf ffmpeg-4.1.tar.xz
cd ffmpeg-4.1
./configure --disable-doc --disable-ffmpeg --disable-ffplay --disable-debug --prefix=/opt/score-sdk/ffmpeg --pkg-config-flags="--static" --enable-gpl --enable-version3 --disable-openssl --disable-securetransport --disable-videotoolbox --disable-network --disable-iconv --disable-lzma
make -j$(nproc)
make install
cd ..