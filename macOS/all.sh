#!/bin/bash -eux

# ./deps.sh
# ./llvm-deps.sh

# Build stage: core | media | full (default). 'media' expects the core SDK to
# already be extracted into $INSTALL_PREFIX. macOS uses the Xcode clang for both
# stages, so there is no toolchain hand-off to worry about.
STAGE="${STAGE:-full}"

build_core() {
  ./freetype.sh
  # Before qt.sh -- see the note in Linux/build-all.sh (-system-webp).
  ./media-deps.sh libjpeg webp
  ./qt.sh
  # ./fftw.sh
  ./llvm-libs.sh
}

build_media() {
  ./openssl.sh    # ffmpeg tls+dtls (whip/srtp) and libsrt encryption
  ./media-deps.sh # codecs + SRT, into $INSTALL_PREFIX
  ./ffmpeg.sh
  # ./sndfile.sh
  # ./portaudio.sh
  ./sdl.sh
  ./jack.sh
  ./faust.sh      # needs llvm-config from the core's $INSTALL_PREFIX/llvm-libs
  ./ysfx.sh
}

# `extra`: per-addon prebuilt deps shipped as their own release assets, kept out
# of `full` so the base SDK build is unaffected. See common/build-onnxruntime.sh.
build_extra() {
  ./onnxruntime.sh
}

case "$STAGE" in
  core)  build_core ;;
  media) build_media ;;
  extra) build_extra ;;
  full)  build_core; build_media ;;
  *) echo "all.sh: unknown STAGE='$STAGE' (expected core|media|extra|full)" >&2; exit 1 ;;
esac

# `extra` ships its own per-dep tarballs, not the SDK prefix -- skip the packaging below.
if [[ "$STAGE" == "extra" ]]; then exit 0; fi

if [[ "$STAGE" == "core" ]]; then
  # Ship only the core-owned top-level dirs (allowlist); media is added later.
  core_paths=()
  for d in llvm-libs qt6-static freetype harfbuzz; do
    [[ -e "$INSTALL_PREFIX/$d" ]] && core_paths+=("$INSTALL_PREFIX/$d")
  done
  # xz (not gzip): the x86_64 core exceeds the 2GB GitHub release-asset limit
  # enforced by .github/publish-core.sh when gzipped. xz roughly halves it and
  # matches the Linux core format. XZ_OPT (-T0 -9: all cores, max dictionary) is
  # best-effort -- honoured when tar shells out to the external xz (installed via
  # deps.sh); ignored by bsdtar's internal liblzma, which still yields xz ~level6,
  # itself well under the limit. Either way the output is a valid .tar.xz.
  XZ_OPT='-T0 -9' tar caf sdk-core-macOS-$TARGET_ARCH.tar.xz "${core_paths[@]}"
else
  # media/full: the whole merged prefix is the shippable SDK. xz (not gzip) for
  # a smaller artifact and format uniformity with the Linux SDK. NB: consumers
  # fetch this by name -- the extension change must be mirrored downstream.
  # $SDK_ARCH, not $TARGET_ARCH: score fetches sdk-macOS-aarch64.tar.xz, the same
  # spelling as the Linux/mingw assets and as /opt/ossia-sdk-aarch64.
  XZ_OPT='-T0 -9' tar caf sdk-macOS-$SDK_ARCH.tar.xz $INSTALL_PREFIX
fi
