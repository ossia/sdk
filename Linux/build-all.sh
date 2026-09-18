#!/bin/bash -eu

# Build the SDK in one of three stages (see the core/media split):
#   core  : slow-moving libs (llvm, qt, openssl, sysroot=zlib/freetype/...)
#   media : fast-moving libs built ON TOP of an already-installed core
#   full  : everything, in dependency order (default; local dev & one-shot CI)
# Default is 'full' so a bare ./build-all.sh keeps working as before.
STAGE="${STAGE:-full}"

build_core() {
  ./llvm.sh || return
  ./zlib.sh || return
  ./openssl.sh || return
  ./freetype.sh || return
  # Before qt.sh: qtimageformats compiles its bundled libwebp into QWebpPlugin
  # unless -system-webp (common/qtfeatures) is set, which would put a second
  # copy of libwebp in every statically linked score alongside libavcodec's.
  ./media-deps.sh libjpeg webp || return
  ./qt.sh || return
  # ./fontconfig.sh
}

build_media() {
  ./faust.sh      || return # needs llvm-config from the core's $INSTALL_PREFIX/llvm
  ./media-deps.sh || return # codecs + SRT + hwaccel headers, into the sysroot ffmpeg reads
  ./ffmpeg.sh     || return
  ./fftw.sh       || return
  ./sdl.sh        || return
  ./portaudio.sh  || return
  ./jack.sh       || return
  ./pipewire.sh   || return
  ./lv2.sh        || return
  ./ysfx.sh       || return # links freetype from the core's sysroot
  # ./qgnomeplatform.sh
}

# cmake is a build tool (populates $SDK_ROOT/cmake in the build tree, no prefix
# writes); it is needed by every stage, including a standalone media build.
./cmake.sh || exit

case "$STAGE" in
  core)
    build_core
    ;;
  media)
    build_media
    ;;
  full)
    ./llvm.sh || exit $?
    ./zlib.sh || exit $?
    ./openssl.sh || exit $?
    ./freetype.sh || exit $?
    ./media-deps.sh libjpeg webp || exit $?
    ./qt.sh || exit $?
    ./faust.sh || exit $?
    ./media-deps.sh || exit $?
    ./ffmpeg.sh || exit $?
    ./fftw.sh || exit $?
    ./sdl.sh || exit $?
    ./portaudio.sh || exit $?
    ./jack.sh || exit $?
    ./pipewire.sh || exit $?
    ./lv2.sh || exit $?
    ./ysfx.sh || exit $?
    ;;
  *) echo "build-all.sh: unknown STAGE='$STAGE' (expected core|media|full)" >&2; exit 1 ;;
esac
