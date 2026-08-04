#!/bin/bash
# Shared recipe for the `extra` SDK stage: produce a per-platform onnxruntime an
# addon can drop in. WASM is built from source with JSPI so it compiles with
# `-fwasm-exceptions` (matching score's link); the public prebuilts are legacy-EH
# and leave __resumeException undefined at link. Desktop repackages the upstream
# release, whose native EH already matches. A thin <platform>/onnxruntime.sh sets
# EXTRA_PLATFORM and calls build_onnxruntime; output lands at
#   $SDK_ROOT/onnxruntime-<platform>[-<arch>].tar.xz
source ../common/versions.sh

build_onnxruntime() {
  local plat="${EXTRA_PLATFORM:?set EXTRA_PLATFORM}"
  local arch="${CPU_ARCH:-${TARGET_ARCH:-$(uname -m)}}"
  local stage tag out
  stage="$PWD/.ort-stage"; rm -rf "$stage"; mkdir -p "$stage/lib" "$stage/include"

  if [[ "$plat" == "wasm" ]]; then
    tag="wasm"
    [[ -d onnxruntime ]] || git clone --quiet --depth 1 \
      --branch "v$ONNXRUNTIME_VERSION" https://github.com/microsoft/onnxruntime
    (
      cd onnxruntime
      # --enable_wasm_jspi selects "-fwasm-exceptions -s WASM_LEGACY_EXCEPTIONS=0"
      # (adjust_global_compile_flags.cmake); it is mutually exclusive with the
      # legacy exception-catching flag, which is exactly the EH ABI score links.
      python3 tools/ci_build/build.py \
        --config Release --build_dir build-wasm \
        --build_wasm_static_lib --enable_wasm_simd --enable_wasm_threads \
        --enable_wasm_jspi --skip_tests --parallel --compile_no_warning_as_error
      cp build-wasm/Release/libonnxruntime_webassembly.a "$stage/lib/libonnxruntime.a"
      cp -a include/onnxruntime/core/session/. "$stage/include/"
    )
    # Non-negotiable guard: if JSPI did not take, the archive still needs the
    # legacy __resumeException and score's link fails exactly as before.
    if "${EMSDK:?EMSDK unset}/upstream/bin/llvm-nm" "$stage/lib/libonnxruntime.a" \
         | grep -q ' U __resumeException'; then
      echo "build-onnxruntime: wasm lib still references __resumeException (legacy EH)" >&2
      exit 1
    fi
  else
    tag="$plat-$arch"
    local asset
    case "$plat" in
      macos)   asset="onnxruntime-osx-universal2-$ONNXRUNTIME_VERSION.tgz" ;;
      linux)   local a=x64; [[ "$arch" =~ (aarch64|arm64) ]] && a=aarch64
               asset="onnxruntime-linux-$a-$ONNXRUNTIME_VERSION.tgz" ;;
      windows) asset="onnxruntime-win-x64-$ONNXRUNTIME_VERSION.zip" ;;
      *) echo "build-onnxruntime: unknown EXTRA_PLATFORM='$plat'" >&2; exit 1 ;;
    esac
    curl -ksSLOJ "https://github.com/microsoft/onnxruntime/releases/download/v$ONNXRUNTIME_VERSION/$asset"
    local d; d="$(mktemp -d)"
    case "$asset" in *.zip) unzip -q "$asset" -d "$d" ;; *) tar xaf "$asset" -C "$d" ;; esac
    local root; root="$(find "$d" -maxdepth 1 -type d -name 'onnxruntime-*' | head -1)"
    cp -a "$root/lib/." "$stage/lib/"
    cp -a "$root/include/." "$stage/include/"
    rm -rf "$d"
  fi

  out="$SDK_ROOT/onnxruntime-$tag.tar.xz"
  ( cd "$stage" && XZ_OPT='-T0 -9' tar caf "$out" . )
  rm -rf "$stage"
  echo "build-onnxruntime: produced $out"
}
