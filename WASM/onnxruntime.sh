#!/bin/bash -eux
source ./common.sh
source ../common/build-onnxruntime.sh
EXTRA_PLATFORM=wasm build_onnxruntime
