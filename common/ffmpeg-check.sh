# Post-configure assertions for ffmpeg, sourced by <platform>/ffmpeg.sh.
#
# ffmpeg's configure is permissive about *filters*: a filter whose dependency
# is missing is dropped without a word, only libraries requested with
# --enable-X fail loudly. That is how the sdk36-era tarballs ended up with
# --enable-vulkan and zero *_vulkan filters (no SPIR-V compiler on PATH), and
# nobody noticed until libavfilter.a was inspected with nm. So every GPU filter
# family the SDK is supposed to ship is asserted here, against ffbuild/config.mak
# of the configured tree, and a missing one fails the build with the config.log
# tail shown -- the same treatment Linux/ffmpeg.sh already gives x86 assembly.
#
# Usage, from inside the configured build directory:
#   ffmpeg_require_config CONFIG_GBLUR_VULKAN_FILTER CONFIG_LIBPLACEBO_FILTER ...
#   ffmpeg_report_gpu_filters          # human-readable summary in the log

ffmpeg_require_config() {
  local mak="ffbuild/config.mak" missing=() k
  [[ -f "$mak" ]] || { echo "ffmpeg-check: $mak not found (run from the configured tree)" >&2; return 1; }
  for k in "$@"; do
    grep -qx "$k=yes" "$mak" || missing+=("$k")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ffmpeg-check: configure silently dropped: ${missing[*]}" >&2
    echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"
    return 1
  fi
  echo "ffmpeg-check: ok: $*"
}

ffmpeg_report_gpu_filters() {
  local mak="ffbuild/config.mak"
  echo "ffmpeg-check: GPU filters enabled:"
  for fam in VULKAN CUDA VT VIDEOTOOLBOX COREIMAGE D3D11 AMF QSV OPENCL LIBPLACEBO; do
    local n; n=$(grep -c -E "^CONFIG_([A-Z0-9_]+_)?${fam}(SRC)?_FILTER=yes" "$mak" || true)
    printf '  %-12s %s\n' "$fam" "$n"
  done
  grep -E '^CONFIG_[A-Z0-9_]+_(VULKAN|CUDA|VT|VIDEOTOOLBOX|D3D11|AMF)_FILTER=yes|^CONFIG_(LIBPLACEBO|COREIMAGE|COREIMAGESRC)_FILTER=yes' "$mak" \
    | sed -e 's/^CONFIG_//' -e 's/_FILTER=yes$//' | tr 'A-Z' 'a-z' | sort | tr '\n' ' '
  echo
}
