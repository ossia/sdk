#!/bin/bash
# Shared recipe for the `extra` SDK stage: produce a per-platform onnxruntime an
# addon can drop in.
#
#   wasm        : STATIC lib built from source with JSPI => -fwasm-exceptions,
#                 matching score's -sJSPI link (public prebuilts are legacy-EH
#                 and leave __resumeException undefined at link).
#   arm desktop : SHARED lib (libonnxruntime.so/.dylib) built from source with the
#                 accelerator EPs that help score's real-time-CV workload -- MLAS
#                 +KleidiAI (default on aarch64) plus XNNPACK, and CoreML on Apple.
#                 Shared, not static: it bundles the EPs + third-party deps
#                 (abseil/protobuf/onnx/re2/...) inside the .so, so the consumer
#                 links one library and there are no protobuf/Abseil symbol clashes
#                 with score's own copies. (Static is only needed for wasm.)
#                 NOT enabled: ACL, ArmNN (removed from ORT v1.25), DirectML,
#                 WebGPU, Vulkan/OpenCL. QNN/RKNPU/Hailo are separate runtimes,
#                 not ORT EPs -- handled as their own `extra` artifacts.
#   x86_64      : the upstream prebuilt is already well-tuned -> repackage.
#
# Output: $SDK_ROOT/onnxruntime-<platform>[-<arch>].tar.xz
source ../common/versions.sh

_ort_src() {   # ensure the pinned onnxruntime source tree exists
  [[ -d onnxruntime ]] || git clone --quiet --depth 1 --recursive \
    --branch "v$ONNXRUNTIME_VERSION" https://github.com/microsoft/onnxruntime
}

# A static archive may legitimately leave libc/libc++ symbols undefined, so grepping
# for individual names only catches what we already know about. Link a trivial user
# with score's flags instead: anything the archive needs and cannot get is an error
# here rather than in every consumer.
_ort_wasm_linktest() {   # stage
  local stage="$1" d; d="$(mktemp -d)"
  cat > "$d/t.cpp" <<'EOF'
#include <onnxruntime_c_api.h>
int main() { return OrtGetApiBase() == nullptr; }
EOF
  em++ -fwasm-exceptions -pthread -msimd128 -sJSPI -sERROR_ON_UNDEFINED_SYMBOLS=1 \
    -I"$stage/include" "$d/t.cpp" "$stage/lib/libonnxruntime.a" -o "$d/t.js"
  rm -rf "$d"
}

_ort_headers() {   # stage -- public C/C++ API + enabled-EP provider factory headers
  local stage="$1"
  cp -a onnxruntime/include/onnxruntime/core/session/. "$stage/include/"
  for h in coreml/coreml_provider_factory.h xnnpack/xnnpack_provider_factory.h; do
    [[ -f "onnxruntime/include/onnxruntime/core/providers/$h" ]] &&
      cp "onnxruntime/include/onnxruntime/core/providers/$h" "$stage/include/"
  done
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
        # build.py hardcodes cmake/external/emsdk, both to install a toolchain and
        # to locate Emscripten.cmake. Point it at ours so it cannot pull its own.
        # It is a submodule path, so `git submodule sync` refuses to see a symlink
        # there; _ort_src already cloned recursively, so skip that step.
        rm -rf cmake/external/emsdk
        ln -s "${EMSDK:?EMSDK unset}" cmake/external/emsdk
        # $CXXFLAGS et al. reach CMAKE_CXX_FLAGS and add -mrelaxed-simd, which turns
        # on MLAS dispatch declarations whose definitions ORT never compiles. Its own
        # flags already match what score links with.
        env -u CFLAGS -u CXXFLAGS -u LDFLAGS \
        python3 tools/ci_build/build.py \
          --config Release --build_dir build-wasm \
          --build_wasm_static_lib --enable_wasm_simd --enable_wasm_threads \
          --enable_wasm_jspi --skip_tests --parallel --compile_no_warning_as_error \
          --emsdk_version "${EMSDK_VERSION:?EMSDK_VERSION unset}" --skip_submodule_sync \
          --cmake_extra_defines onnxruntime_BUILD_UNIT_TESTS=OFF
        cp build-wasm/Release/libonnxruntime_webassembly.a "$stage/lib/libonnxruntime.a"
        cp -a include/onnxruntime/core/session/. "$stage/include/" )
      _ort_wasm_linktest "$stage"
      ;;

    macos)
      tag="macos-$arch"
      if [[ "$arch" =~ (arm64|aarch64) ]]; then
        _ort_src
        ( cd onnxruntime
          python3 tools/ci_build/build.py \
            --config Release --build_dir build-mac --parallel --skip_tests \
            --use_coreml --use_xnnpack --osx_arch arm64 --apple_deploy_target 13.3 \
            --enable_lto --build_shared_lib \
            --cmake_extra_defines onnxruntime_BUILD_UNIT_TESTS=OFF )
        cp onnxruntime/build-mac/Release/libonnxruntime*.dylib "$stage/lib/"
        _ort_headers "$stage"
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
            --use_xnnpack --enable_lto --build_shared_lib \
            --cmake_extra_defines onnxruntime_BUILD_UNIT_TESTS=OFF \
                                  onnxruntime_USE_ARM_NEON_NCHWC=ON )
        cp -a onnxruntime/build-linux/Release/libonnxruntime.so* "$stage/lib/"
        _ort_headers "$stage"
      else
        _ort_repackage linux "$arch" "$stage"
      fi
      ;;

    windows) tag="windows-$arch"; _ort_repackage windows "$arch" "$stage" ;;
    *) echo "build-onnxruntime: unknown EXTRA_PLATFORM='$plat'" >&2; exit 1 ;;
  esac

  # Versioned, so a consumer can pin the onnxruntime it wants rather than whatever
  # the release happens to carry.
  out="$SDK_ROOT/onnxruntime-$ONNXRUNTIME_VERSION-$tag.tar.xz"
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
