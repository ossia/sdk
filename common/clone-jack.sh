#!/bin/bash

source ../common/versions.sh

if [[ ! -d jack2 ]]; then
  git clone https://github.com/jackaudio/jack2
fi