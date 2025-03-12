#!/bin/bash -eu

source ../common/versions.sh
rm -rf pipewire
if [[ ! -d pipewire ]]; then
(
  curl -ksSLOJ https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/$PIPEWIRE_VERSION/pipewire-$PIPEWIRE_VERSION.tar.gz
  tar xaf pipewire-$PIPEWIRE_VERSION.tar.gz
  rm -rf pipewire-$PIPEWIRE_VERSION.tar.gz
  #$GIT clone https://github.com/PipeWire/pipewire
)
fi