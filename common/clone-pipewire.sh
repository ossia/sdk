#!/bin/bash -eu

source ../common/versions.sh

if [[ ! -d pipewire-$PIPEWIRE_VERSION ]]; then
  (
    rm -rf pipewire-$PIPEWIRE_VERSION.tar.gz
    curl -ksSLOJ https://github.com/PipeWire/pipewire/archive/refs/tags/$PIPEWIRE_VERSION.tar.gz
    tar xaf pipewire-$PIPEWIRE_VERSION.tar.gz
    rm -rf pipewire-$PIPEWIRE_VERSION.tar.gz
  )
fi
