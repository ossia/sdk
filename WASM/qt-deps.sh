#!/bin/bash -eux

source ./common.sh
# Use the shared clone path rather than maintaining a second Qt checkout
# implementation. This keeps qtbase/qtshadertools pins, Gerrit picks, and local
# module patches identical across native and WASM builds.
source ../common/clone-qt.sh
