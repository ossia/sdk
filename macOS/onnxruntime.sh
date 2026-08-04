#!/bin/bash -eux
source ./common.sh
source ../common/build-onnxruntime.sh
EXTRA_PLATFORM=macos build_onnxruntime
