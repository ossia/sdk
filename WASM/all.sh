#!/bin/bash -eux

# Full WASM SDK build orchestrator (mirrors macOS/all.sh). Each step runs as its
# own process, so per-script `cd`s do not leak; common.sh re-sources emsdk_env.sh
# once emscripten.sh has installed it, putting emcc/em++ on PATH for later steps.
#
# Build order matters:
#   emscripten -> the toolchain everything else cross-compiles with
#   llvm       -> Faust links against it (JIT DSP -> wasm in the browser)
#   qt         -> host tools build first, then the wasm cross-build uses them
#   ffmpeg/faust (media) -> built on top of llvm + the emsdk sysroot
#
# STAGE=core|media|full (default full) exists for parity with the other
# platforms / future core-media caching; today CI runs 'full'.

cd "$(dirname "$0")"
source ./common.sh

STAGE="${STAGE:-full}"

build_core() {
  ./emscripten.sh
  # LLVM disabled for now: the wasm LLVM cross-build is very slow and needs a
  # version-matched host llvm-tblgen. We rely on emscripten's bundled LLVM
  # instead. Re-enable together with faust below when needed.
  # ./llvm-deps.sh
  # ./llvm.sh
  ./qt-deps.sh
  ./qt.sh
}

build_media() {
  ./ffmpeg.sh
  # faust needs the wasm LLVM built above (LLVM_DIR=$INSTALL_PREFIX/llvm), so it
  # is disabled while LLVM is. Re-enable both together.
  # ./faust.sh
}

case "$STAGE" in
  core)  build_core ;;
  media) build_media ;;
  full)  build_core; build_media ;;
  *) echo "all.sh: unknown STAGE='$STAGE' (expected core|media|full)" >&2; exit 1 ;;
esac

# Package the whole prefix (toolchain + libs) as the shippable SDK. xz for the
# best ratio; the tree (emsdk + llvm + Qt) is large.
if [[ "$STAGE" != "core" ]]; then
  XZ_OPT='-T0 -9' tar caf "$SDK_ROOT/sdk-wasm.tar.xz" "$INSTALL_PREFIX"
fi
