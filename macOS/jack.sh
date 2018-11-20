#!/bin/bash

git clone https://github.com/jackaudio/jack2
mkdir -p /opt/score-sdk/jack/include
cp -rf jack2/common/jack /opt/score-sdk/jack/include/
