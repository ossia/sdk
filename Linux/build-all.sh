#!/bin/bash -eu

# Build the SDK in one of three stages (see the core/media split):
#   core  : slow-moving libs (llvm, qt, openssl, sysroot=zlib/freetype/...)
#   media : fast-moving libs built ON TOP of an already-installed core
#   full  : everything, in dependency order (default; local dev & one-shot CI)
# Default is 'full' so a bare ./build-all.sh keeps working as before.
STAGE="${STAGE:-full}"

build_core() {
  ./llvm.sh
  ./zlib.sh
  ./openssl.sh
  ./freetype.sh
  ./qt.sh
  # ./fontconfig.sh
}

build_media() {
  ./faust.sh      # needs llvm-config from the core's $INSTALL_PREFIX/llvm
  ./ffmpeg.sh
  ./fftw.sh
  ./sdl.sh
  ./portaudio.sh
  ./jack.sh
  ./pipewire.sh
  ./lv2.sh
  ./ysfx.sh       # links freetype from the core's sysroot
  # ./qgnomeplatform.sh
}

# cmake is a build tool (populates $SDK_ROOT/cmake in the build tree, no prefix
# writes); it is needed by every stage, including a standalone media build.
./cmake.sh

case "$STAGE" in
  core)  build_core ;;
  media) build_media ;;
  full)  build_core; build_media ;;
  *) echo "build-all.sh: unknown STAGE='$STAGE' (expected core|media|full)" >&2; exit 1 ;;
esac
