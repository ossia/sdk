#!/bin/bash
# Shared recipe for the `extra` SDK stage: produce a per-platform onnxruntime an
# addon can drop in.
#
#   wasm        : build from source with JSPI => -fwasm-exceptions, matching
#                 score's -sJSPI link (the public prebuilts are legacy-EH and
#                 leave __resumeException undefined at link).
#   arm desktop : build from source with the accelerator EPs that actually help
#                 score's real-time-CV workload -- MLAS+KleidiAI (default) plus
#                 XNNPACK, and CoreML on Apple. The official prebuilts are
#                 CPU-only MLAS with no XNNPACK/CoreML, so we build our own.
#                 (ACL/ArmNN/DirectML/WebGPU are deliberately NOT enabled -- see
#                 docs; ArmNN was removed from ORT in v1.25, the rest regress or
#                 are unmaintained. QNN is a separate quantized-only artifact.)
#   x86_64      : the upstream prebuilt is already well-tuned -> repackage.
#
# Output: $SDK_ROOT/onnxruntime-<platform>[-<arch>].tar.xz
#
# NB: a from-source static ORT is a SET of archives (libonnxruntime_*.a + per-EP
# libs + third-party: abseil, protobuf-lite, onnx, re2, flatbuffers, cpuinfo,
# nlohmann_json, ...), not one .a. We stage them all under lib/ and let the
# consumer link the group; matching the compiler score uses avoids LTO/ABI skew.
source ../common/versions.sh

_ort_src() {   # ensure the pinned onnxruntime source tree exists
  [[ -d onnxruntime ]] || git clone --quiet --depth 1 --recursive \
    --branch "v$ONNXRUNTIME_VERSION" https://github.com/microsoft/onnxruntime
}

build_onnxruntime() {
  local plat="${EXTRA_PLATFORM:?set EXTRA_PLATFORM}"
  local arch="${CPU_ARCH:-${TARGET_ARCH:-$(uname -m)}}"
  local stage tag out
  stage="$PWD/.ort-stage"; rm -rf "$stage"; mkdir -p "$stage/lib" "$stage/include"

  case "$plat" in
    wasm)
      tag="wasm"; _ort_src
      ( cd onnxruntime
        # --enable_wasm_jspi -> "-fwasm-exceptions -s WASM_LEGACY_EXCEPTIONS=0"
        python3 tools/ci_build/build.py \
          --config Release --build_dir build-wasm \
          --build_wasm_static_lib --enable_wasm_simd --enable_wasm_threads \
          --enable_wasm_jspi --skip_tests --parallel --compile_no_warning_as_error
        cp build-wasm/Release/libonnxruntime_webassembly.a "$stage/lib/libonnxruntime.a"
        cp -a include/onnxruntime/core/session/. "$stage/include/" )
      # Guard: JSPI must have removed the legacy __resumeException reference.
      if "${EMSDK:?EMSDK unset}/upstream/bin/llvm-nm" "$stage/lib/libonnxruntime.a" \
           | grep -q ' U __resumeException'; then
        echo "build-onnxruntime: wasm lib still references __resumeException" >&2; exit 1
      fi
      ;;

    macos)
      tag="macos-$arch"
      if [[ "$arch" =~ (arm64|aarch64) ]]; then
        _ort_src
        ( cd onnxruntime
          # CoreML (ANE/GPU) + XNNPACK on top of MLAS+KleidiAI (default).
          # --build_apple_framework merges the many static libs into one.
          python3 tools/ci_build/build.py \
            --config Release --build_dir build-mac --parallel --skip_tests \
            --use_coreml --use_xnnpack --osx_arch arm64 --apple_deploy_target 13.3 \
            --enable_lto --build_apple_framework \
            --cmake_extra_defines onnxruntime_BUILD_UNIT_TESTS=OFF )
        # onnxruntime.framework carries a single merged static lib + headers.
        local fw; fw="$(find onnxruntime/build-mac -name onnxruntime.framework -type d | head -1)"
        cp -a "$fw/Headers/." "$stage/include/"
        cp    "$fw/onnxruntime" "$stage/lib/libonnxruntime.a"
      else
        _ort_repackage macos "$arch" "$stage"
      fi
      ;;

    linux)
      tag="linux-$arch"
      if [[ "$arch" =~ (aarch64|arm64) ]]; then
        _ort_src
        ( cd onnxruntime
          python3 tools/ci_build/build.py \
            --config Release --build_dir build-linux --parallel --skip_tests \
            --use_xnnpack --enable_lto \
            --cmake_extra_defines onnxruntime_BUILD_UNIT_TESTS=OFF \
                                  onnxruntime_USE_ARM_NEON_NCHWC=ON )
        # Static ORT = a set of archives; ship them all + a link order manifest.
        find onnxruntime/build-linux/Release -name 'lib*.a' -exec cp {} "$stage/lib/" \;
        cp -a onnxruntime/include/onnxruntime/core/session/. "$stage/include/"
        ( cd "$stage/lib" && ls libonnxruntime*.a lib*.a 2>/dev/null | sort -u > ../link-order.txt )
      else
        _ort_repackage linux "$arch" "$stage"
      fi
      ;;

    windows) tag="windows-$arch"; _ort_repackage windows "$arch" "$stage" ;;
    *) echo "build-onnxruntime: unknown EXTRA_PLATFORM='$plat'" >&2; exit 1 ;;
  esac

  out="$SDK_ROOT/onnxruntime-$tag.tar.xz"
  ( cd "$stage" && XZ_OPT='-T0 -9' tar caf "$out" . )
  rm -rf "$stage"
  echo "build-onnxruntime: produced $out"
}

_ort_repackage() {   # plat arch stage -- repackage the upstream prebuilt (x86_64/win)
  local plat="$1" arch="$2" stage="$3" asset
  case "$plat" in
    macos)   asset="onnxruntime-osx-universal2-$ONNXRUNTIME_VERSION.tgz" ;;
    linux)   asset="onnxruntime-linux-x64-$ONNXRUNTIME_VERSION.tgz" ;;
    windows) asset="onnxruntime-win-x64-$ONNXRUNTIME_VERSION.zip" ;;
  esac
  curl -ksSLOJ "https://github.com/microsoft/onnxruntime/releases/download/v$ONNXRUNTIME_VERSION/$asset"
  local d; d="$(mktemp -d)"
  case "$asset" in *.zip) unzip -q "$asset" -d "$d" ;; *) tar xaf "$asset" -C "$d" ;; esac
  local root; root="$(find "$d" -maxdepth 1 -type d -name 'onnxruntime-*' | head -1)"
  cp -a "$root/lib/." "$stage/lib/"; cp -a "$root/include/." "$stage/include/"
  rm -rf "$d"
}
