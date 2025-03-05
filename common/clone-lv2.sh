#!/bin/bash

if [[ ! -d lv2kit ]]; then
  git clone --recursive -j12 https://github.com/lv2/lv2kit
fi