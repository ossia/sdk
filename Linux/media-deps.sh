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

# libsrt must find the openssl the CORE stage built, exactly as on macOS and
# MSYS -- Linux was the one platform missing this and it was the first thing to
# fail once the media stage actually ran in CI: srt's CMakeLists does an
# unconditional find_package(OpenSSL) and the build container has no system
# openssl-devel, so it died with "Could NOT find OpenSSL ... (missing:
# OPENSSL_CRYPTO_LIBRARY OPENSSL_INCLUDE_DIR)".
#
# lib AND lib64: Linux/openssl.sh passes no --libdir, so OpenSSL picks, and it
# picks lib64 on this container. Same reason ffmpeg.sh names both.
export PKG_CONFIG_PATH="$INSTALL_PREFIX/openssl/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
export MD_SRT_EXTRA_FLAGS=(
  -DUSE_ENCLIB=openssl
  -DOPENSSL_ROOT_DIR="$INSTALL_PREFIX/openssl"
  -DOPENSSL_USE_STATIC_LIBS=ON
  # srt 1.5.6 renamed the flag and warns on the old one; pass both so the
  # recipe works either side of that rename.
  -DSRT_USE_OPENSSL_STATIC_LIBS=ON
)

source ../common/build-media-deps.sh

build_media_deps
