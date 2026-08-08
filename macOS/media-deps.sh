#!/bin/bash -eu

# ffmpeg's codec / protocol dependencies. Runs in the MEDIA stage, after
# openssl.sh (libsrt links it) and before ffmpeg.sh.
#
# macOS keeps the SDK prefix itself as the dep prefix rather than a sysroot/
# subdir: common.sh already pins PKG_CONFIG_LIBDIR to $INSTALL_PREFIX/lib/pkgconfig
# so that nothing can leak in from Homebrew, and putting the .pc files anywhere
# else would mean widening that.

source ./common.sh

# No nvcodec_headers / amf_headers / vulkan_headers here: ffnvcodec and AMF are
# Windows+Linux only, and Vulkan on macOS would mean shipping MoltenVK. Apple
# hardware is covered by VideoToolbox, which needs no external package at all
# (see common/ffmpeg-features.macos).
# snappy is prepended only here: Linux and MSYS build it in their core stage
# (zlib.sh) and macOS has no equivalent, so ffmpeg's --enable-libsnappy would
# otherwise fail to configure on mac.
export MEDIA_DEPS_LIST="snappy $(sed -e 's/#.*$//' ../common/media-deps-codecs)"
# SVT-JPEG-XS is x86-only upstream (see common/media-deps-codecs.x86_64).
if [[ "$TARGET_ARCH" == "x86_64" ]]; then
  MEDIA_DEPS_LIST="$MEDIA_DEPS_LIST $(sed -e 's/#.*$//' ../common/media-deps-codecs.x86_64)"
fi

export MEDIA_DEPS_PREFIX="$INSTALL_PREFIX"

# Build the deps for ONE architecture even on the x86_64 leg, which ships fat
# x86_64+x86_64h ffmpeg libraries: ld64 links an x86_64h binary against plain
# x86_64 archives (verified on macmini-m1), so the second slice would be pure
# cost. $CFLAGS carries both -arch flags for exactly that fat ffmpeg build, so
# rebuild the flags here from $CFLAGS_NOARCH instead.
if [[ "$TARGET_ARCH" == "arm64" ]]; then
  MEDIA_DEPS_ARCH=arm64
else
  MEDIA_DEPS_ARCH=x86_64
fi
export CFLAGS="$CFLAGS_NOARCH -arch $MEDIA_DEPS_ARCH"
export CXXFLAGS="$CFLAGS_NOARCH -arch $MEDIA_DEPS_ARCH"
export LDFLAGS="${LDFLAGS:-} -arch $MEDIA_DEPS_ARCH"
# cmake reads this from the environment; overrides the "x86_64;x86_64h" that
# common.sh exports for the fat builds.
export CMAKE_OSX_ARCHITECTURES="$MEDIA_DEPS_ARCH"

# libsrt must find the openssl we just built, not a Homebrew one.
export MD_SRT_EXTRA_FLAGS=(
  -DUSE_ENCLIB=openssl
  -DOPENSSL_ROOT_DIR="$INSTALL_PREFIX/openssl"
  -DOPENSSL_USE_STATIC_LIBS=ON
)

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
