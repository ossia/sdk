#!/bin/bash

wget https://github.com/mesonbuild/meson/releases/download/$MESON_VERSION/meson-$MESON_VERSION.tar.gz
tar xaf meson-$MESON_VERSION.tar.gz
rm -rf meson-$MESON_VERSION.tar.gz

