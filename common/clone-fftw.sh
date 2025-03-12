#!/bin/bash

source ../common/versions.sh

if [[ ! -d fftw-$FFTW_VERSION.tar.gz ]]; then
  curl -ksSLOJ http://fftw.org/fftw-$FFTW_VERSION.tar.gz
  tar xaf fftw-$FFTW_VERSION.tar.gz
fi