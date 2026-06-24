#!/bin/bash -e
# -e: stop on the first failing step instead of silently packaging an incomplete
# SDK (this build has no other error checking between steps).

# Drives the full Windows/MSYS2 build. Honours TARGET_ARCH (x86_64 | arm64),
# which common.sh maps to the install prefix, toolchain and triple.
source ./common.sh

# Prerequisites are now automated (run ./deps.sh first):
#  - toolchain/python/meson/perl/nasm/cppwinrt/vulkan-headers : deps.sh (pacman)
#  - cppwinrt + vulkan headers copied into the toolchain        : llvm-deps.sh
#  - pkg-config (u-config) and /c/gnu/bin                       : cmake.sh / common.sh
# Note: fftw's configure must use the MSYS2 /usr/bin/sh, not Git-for-Windows'
# "C:/Program Files/Git/.../sh.exe" (spaces break autotools); the default MSYS2
# PATH ordering handles this as long as we do not inherit the runner PATH.

# Build stage: core | media | full (default). 'media' expects the core SDK to
# already be extracted into $INSTALL_PREFIX; common.sh then picks up the core's
# clang.exe + cmake + python from there.
STAGE="${STAGE:-full}"

build_core() {
  ./zlib.sh
  ./freetype.sh
  ./llvm-deps.sh
  ./llvm.sh
  ./qt.sh
}

build_media() {
  ./ffmpeg.sh
  ./fftw.sh
  ./portaudio.sh
  ./sdl.sh
  ./faust.sh
  ./jack.sh
  ./dnssd.sh
  ./ysfx.sh
}

# cmake (+ python) are build tools shipped in the prefix; cmake.sh is idempotent
# and needed by every stage. For a media build they already come from the
# extracted core, but re-running is a cheap no-op.
./cmake.sh

case "$STAGE" in
  core)  build_core ;;
  media) build_media ;;
  full)  build_core; build_media ;;
  *) echo "all.sh: unknown STAGE='$STAGE' (expected core|media|full)" >&2; exit 1 ;;
esac

if [[ "$STAGE" == "core" ]]; then
  # Ship only the core-owned top-level dirs (allowlist); media is added later.
  # Includes the build tools (cmake, python) and the llvm-mingw toolchain so a
  # later media build has everything it needs.
  cd $INSTALL_PREFIX
  core_dirs=()
  for d in llvm llvm-libs qt6-static sysroot freetype cmake python; do
    [[ -e "$INSTALL_PREFIX/$d" ]] && core_dirs+=("$d")
  done
  7z a "$SDK_ROOT/sdk-core-mingw-$SDK_ARCH.7z" "${core_dirs[@]}"
else
  # media/full: the whole merged prefix is the shippable SDK (unchanged name).
  cd $INSTALL_PREFIX
  7z a "$SDK_ROOT/sdk-mingw-$SDK_ARCH.7z" *
fi

