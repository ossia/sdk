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

# ONE architecture, even though the rest of the Intel SDK (Qt, llvm-libs and
# score) stays fat x86_64 + x86_64h.
#
# That works because ld accepts a native Mach-O x86_64 object into an x86_64h
# link: its cpusubtype is CPU_SUBTYPE_X86_64_ALL, and x86_64 code is valid on
# x86_64h hardware. Only LLVM BITCODE (-flto) members cannot be reused across
# subtypes -- ld has to hand each module to codegen for one exact target, so it
# reports "ignoring file ...: found architecture 'x86_64', required architecture
# 'x86_64h'" for every member. SVT-JPEG-XS was the sole dep shipping bitcode,
# which is why ossia/SVT-JPEG-XS turns upstream's unconditional -flto off (see
# common/versions.sh). With that, all twelve archives are native and link into
# both slices. Verified on macmini-x64, Xcode 16.2 / ld-1115.7.3.
#
# Building x86_64h dep slices instead is not possible: nasm cannot emit the
# x86_64h subtype, so every asm codec comes out mixed x86_64+x86_64h and lipo
# refuses to merge it with the x86_64 slice.
#
# $CFLAGS carries every -arch for the fat builds, so rebuild it from
# $CFLAGS_NOARCH for the single arch we want.
if [[ "$TARGET_ARCH" == "arm64" ]]; then
  MEDIA_DEPS_ARCH=arm64
else
  MEDIA_DEPS_ARCH=x86_64
fi
export MEDIA_DEPS_PREFIX="$INSTALL_PREFIX"
export CFLAGS="$CFLAGS_NOARCH -arch $MEDIA_DEPS_ARCH"
export CXXFLAGS="$CFLAGS_NOARCH -arch $MEDIA_DEPS_ARCH"
export LDFLAGS="${LDFLAGS:-} -arch $MEDIA_DEPS_ARCH"
# cmake does not read this from the environment; build-media-deps.sh passes it
# as a -D cache variable and reads it from here.
export CMAKE_OSX_ARCHITECTURES="$MEDIA_DEPS_ARCH"

# libsrt must find the openssl we built, not a Homebrew one.
export MD_SRT_EXTRA_FLAGS=(
  -DUSE_ENCLIB=openssl
  -DOPENSSL_ROOT_DIR="$INSTALL_PREFIX/openssl"
  -DOPENSSL_USE_STATIC_LIBS=ON
)

source ../common/build-media-deps.sh

build_media_deps

# A bitcode member is silent until somebody links an x86_64h binary, which is
# not this script and not even this stage -- so check here rather than let it
# surface as a confusing ffmpeg or score link failure much later.
for a in "$MEDIA_DEPS_PREFIX"/lib/*.a; do
  [[ -e "$a" ]] || continue
  d="$(mktemp -d)"
  ( cd "$d" && ar x "$a" ) 2>/dev/null || { rm -rf "$d"; continue; }
  if file "$d"/*.o 2>/dev/null | grep -q "LLVM bitcode"; then
    echo "media-deps: $(basename "$a") has LLVM bitcode (-flto) members." >&2
    echo "            ld cannot reuse those for an x86_64h link, so a fat" >&2
    echo "            consumer fails with \"required architecture x86_64h\"." >&2
    echo "            Build that dependency without -flto." >&2
    rm -rf "$d"; exit 1
  fi
  rm -rf "$d"
done
