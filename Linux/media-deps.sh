#!/bin/bash -eu

# ffmpeg's codec / protocol / hwaccel dependencies. Runs in the MEDIA stage,
# before ffmpeg.sh. Installs into $INSTALL_PREFIX/sysroot, which is already on
# PKG_CONFIG_PATH (see CentOS/common.release.sh) -- so ffmpeg, and later
# gstreamer, both find these without any extra plumbing.

source ./common.sh clang

# Both hwaccel header packages are safe on every x86_64/aarch64 Linux machine:
# ffmpeg dlopens libcuda/libnvcuvid/libnvidia-encode (NVIDIA), libamfrt64.so
# (AMD) and libvulkan.so.1, and falls back to software when they are missing.
# Deliberately NOT here: vaapi and Intel libvpl/QSV -- both are link-time
# dependencies (libva.so.2 / libvpl.so) and would break the "runs everywhere"
# guarantee. Intel hardware is covered by Vulkan Video via Mesa ANV instead.
export MEDIA_DEPS_LIST="nvcodec_headers amf_headers vulkan_headers $(sed -e 's/#.*$//' ../common/media-deps-codecs)"
# SVT-JPEG-XS is x86-only upstream (see common/media-deps-codecs.x86_64).
if [[ "$CPU_ARCH" == "x86_64" ]]; then
  MEDIA_DEPS_LIST="$MEDIA_DEPS_LIST $(sed -e 's/#.*$//' ../common/media-deps-codecs.x86_64)"
fi

# An explicit list on the command line overrides the default. The core stage
# uses this to build just libwebp before qt.sh: qtimageformats compiles its
# BUNDLED libwebp straight into QWebpPlugin unless -system-webp is configured,
# and a statically linked score would then carry libwebp twice -- once from the
# Qt plugin and once via libavcodec. Same symbols, two copies: an ODR violation
# waiting to bite. Qt is a core-stage build, so the library has to exist before
# it runs.
if [[ $# -gt 0 ]]; then
  MEDIA_DEPS_LIST="$*"
fi

source ../common/build-media-deps.sh

build_media_deps
