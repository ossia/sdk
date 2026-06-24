#!/bin/bash -eux

# ./deps.sh
# ./llvm-deps.sh

# Build stage: core | media | full (default). 'media' expects the core SDK to
# already be extracted into $INSTALL_PREFIX. macOS uses the Xcode clang for both
# stages, so there is no toolchain hand-off to worry about.
STAGE="${STAGE:-full}"

build_core() {
  ./freetype.sh
  ./qt.sh
  # ./fftw.sh
  ./llvm-libs.sh
}

build_media() {
  ./ffmpeg.sh
  # ./sndfile.sh
  # ./portaudio.sh
  ./sdl.sh
  ./jack.sh
  ./faust.sh      # needs llvm-config from the core's $INSTALL_PREFIX/llvm-libs
  ./ysfx.sh
}

case "$STAGE" in
  core)  build_core ;;
  media) build_media ;;
  full)  build_core; build_media ;;
  *) echo "all.sh: unknown STAGE='$STAGE' (expected core|media|full)" >&2; exit 1 ;;
esac

if [[ "$STAGE" == "core" ]]; then
  # Ship only the core-owned top-level dirs (allowlist); media is added later.
  core_paths=()
  for d in llvm-libs qt6-static freetype harfbuzz; do
    [[ -e "$INSTALL_PREFIX/$d" ]] && core_paths+=("$INSTALL_PREFIX/$d")
  done
  tar caf sdk-core-macOS-$TARGET_ARCH.tar.gz "${core_paths[@]}"
else
  # media/full: the whole merged prefix is the shippable SDK (unchanged name).
  tar caf sdk-macOS-$TARGET_ARCH.tar.gz $INSTALL_PREFIX
fi
