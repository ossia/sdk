#!/bin/bash -eu

# ffmpeg's codec / protocol / hwaccel dependencies, into $INSTALL_PREFIX/sysroot
# -- the same prefix zlib.sh already uses and that ffmpeg.sh puts on
# PKG_CONFIG_PATH. Runs in the MEDIA stage, before ffmpeg.sh.

source ./common.sh

# vulkan_headers IS built here rather than taken from MSYS2's
# mingw-w64-$TOOLCHAIN-vulkan-headers: pacman's version floats, ffmpeg 9 needs
# vulkan >= 1.3.277, and a core built before that package was current fails with
# "vulkan requested but not found". Pinning our own copy also keeps MSYS2 out of
# the shipped SDK, same as on Linux and macOS. (llvm-deps.sh still copies the
# pacman headers into the toolchain for Qt's own vulkan feature test.)
#
# Windows gets the widest hardware coverage of any platform, all of it
# dependency-free: NVIDIA via ffnvcodec, AMD via AMF, everything else via
# d3d11va/d3d12va/dxva2 and MediaFoundation (already in ffmpeg.sh), plus Vulkan
# Video on top. All are LoadLibrary-based.
export MEDIA_DEPS_LIST="nvcodec_headers amf_headers vulkan_headers $(sed -e 's/#.*$//' ../common/media-deps-codecs)"
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

# opus on Windows-on-ARM. Its CMake turns OPUS_PRESUME_NEON on automatically
# only when CMAKE_SYSTEM_PROCESSOR matches "aarch64" (cmake/OpusConfig.cmake);
# Windows reports "ARM64", so the check misses and opus falls back to RUNTIME
# NEON detection instead -- for which celt/arm/armcpu.c has no implementation on
# mingw/ARM, and the build stops on its #error: "Configured to use ARM asm but
# no CPU detection method available for your platform."
#
# Linux aarch64 matches the regex and macOS has a working detection method, so
# this is Windows-ARM only. Intrinsics off rather than half-configured: keeping
# NEON would mean hand-defining OPUS_ARM_MAY_HAVE_NEON_INTR alongside
# PRESUME_NEON, a combination upstream ships on no platform. Opus is cheap next
# to video decoding and this is our least performance-critical target, so the
# supported, tested configuration wins. Revisit if opus fixes the regex.
if [[ "$TARGET_ARCH" != "x86_64" ]]; then
  export MD_OPUS_EXTRA_FLAGS=( -DOPUS_DISABLE_INTRINSICS=ON )
fi

# libsrt must find the openssl built by openssl.sh, not a pacman one.
# On Windows-on-ARM there is no openssl (OpenSSL has no mingw arm64 target), so
# build SRT without encryption there rather than fail the leg. ffmpeg's own TLS
# is schannel on Windows and is unaffected either way.
if [[ "$TARGET_ARCH" == "x86_64" ]]; then
  export MD_SRT_EXTRA_FLAGS=(
    -DUSE_ENCLIB=openssl
    -DOPENSSL_ROOT_DIR="$INSTALL_PREFIX_CMAKE/openssl"
    -DOPENSSL_USE_STATIC_LIBS=ON
    # srt 1.5.6 renamed the flag and warns on the old one; pass both so the
    # recipe works either side of that rename.
    -DSRT_USE_OPENSSL_STATIC_LIBS=ON
  )
else
  export MD_SRT_EXTRA_FLAGS=( -DENABLE_ENCRYPTION=OFF )
fi

source ../common/build-media-deps.sh

build_media_deps
