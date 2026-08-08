#!/bin/bash
# Reader for the common/ffmpeg-features* flag files. Mirrors how qt.sh consumes
# common/qtfeatures, with two differences: the files may carry "#" comments, and
# the platform layer is concatenated automatically.
#
#   source ../common/ffmpeg-features.sh
#   ./configure $(ffmpeg_features linux) --prefix=... --extra-cflags="$CFLAGS"
#
# Word-splitting the result is the point -- do NOT quote the call.

ffmpeg_features() {   # <platform> [arch]
  #   platform: linux | macos | mingw | wasm
  #   arch:     x86_64 | aarch64   (optional; adds common/ffmpeg-features.<arch>)
  #
  # The arch layer exists because a few flags are genuinely ISA-dependent rather
  # than OS-dependent -- SVT-JPEG-XS, for one, is x86-only upstream -- and Linux
  # builds both arches from the same ffmpeg-features.linux.
  local platform="${1:?ffmpeg_features: platform required}"
  local arch="${2:-}"
  local common_root="${SDK_COMMON_ROOT:-$(cd "$PWD/.." && pwd -P)}"
  local files=()

  # wasm is self-contained: it shares almost nothing with the desktop set, so
  # the shared file is skipped rather than half-disabled again in the overlay.
  [[ "$platform" != "wasm" ]] && files+=("$common_root/common/ffmpeg-features")
  files+=("$common_root/common/ffmpeg-features.$platform")
  [[ -n "$arch" ]] && files+=("$common_root/common/ffmpeg-features.$arch")

  local f
  for f in "${files[@]}"; do
    if [[ ! -f "$f" ]]; then
      echo "ffmpeg_features: missing $f" >&2
      return 1
    fi
  done

  sed -e 's/#.*$//' "${files[@]}"
}
