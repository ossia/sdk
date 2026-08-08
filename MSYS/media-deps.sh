#!/bin/bash -eu

# ffmpeg's codec / protocol / hwaccel dependencies, into $INSTALL_PREFIX/sysroot
# -- the same prefix zlib.sh already uses and that ffmpeg.sh puts on
# PKG_CONFIG_PATH. Runs in the MEDIA stage, before ffmpeg.sh.

source ./common.sh

# vulkan_headers is absent on purpose: deps.sh installs
# mingw-w64-$TOOLCHAIN-vulkan-headers and llvm-deps.sh copies them into the
# toolchain, so ffmpeg's header-only vulkan probe already finds them here.
#
# Windows gets the widest hardware coverage of any platform, all of it
# dependency-free: NVIDIA via ffnvcodec, AMD via AMF, everything else via
# d3d11va/d3d12va/dxva2 and MediaFoundation (already in ffmpeg.sh), plus Vulkan
# Video on top. All are LoadLibrary-based.
export MEDIA_DEPS_LIST="nvcodec_headers amf_headers $(sed -e 's/#.*$//' ../common/media-deps-codecs)"
# SVT-JPEG-XS is x86-only upstream (see common/media-deps-codecs.x86_64).
if [[ "$SDK_ARCH" == "x86_64" ]]; then
  MEDIA_DEPS_LIST="$MEDIA_DEPS_LIST $(sed -e 's/#.*$//' ../common/media-deps-codecs.x86_64)"
fi

# cmake needs the Windows-style prefix; the shell paths (/c/...) are not
# understood by the native toolchain.
export MEDIA_DEPS_PREFIX="$INSTALL_PREFIX/sysroot"
export MEDIA_DEPS_PREFIX_CMAKE="$INSTALL_PREFIX_CMAKE/sysroot"

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
