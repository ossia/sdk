# GPU filter dependencies for ffmpeg: glslang and libplacebo.
#
# Sourced by <platform>/media-deps.sh AFTER common/build-media-deps.sh and
# BEFORE build_media_deps, so the recipes below are found by the same
# "_md_build_$dep" dispatch. They live in their own file, not in
# build-media-deps.sh, because that file is one of the CORE hash inputs
# (.github/actions/core-hash): touching it rebuilds every platform's core
# (llvm + qt, hours) for a change that only the media stage consumes.
#
# What these unlock in ffmpeg (all of it is opted into explicitly, see
# common/ffmpeg-features.* and <platform>/ffmpeg.sh):
#
#  glslang    ffmpeg 9 compiles its Vulkan filter shaders at BUILD time with a
#             glslang/glslc binary (configure: probe_glslc); there is no runtime
#             dependency. Without a compiler on PATH configure silently drops
#             all 18 *_vulkan filters and keeps only the Vulkan hwaccels -- the
#             sdk36-era tarballs shipped exactly that, and nothing noticed until
#             `nm` was run on libavfilter.a. Building our own also gives
#             libplacebo the static SPIR-V compiler library it links.
#  libplacebo the `libplacebo` filter: tone mapping, colour management, dithering,
#             scaling and user GLSL hooks on Vulkan frames. ffmpeg 9 needs
#             >= 7.351.0 (configure: require_pkg_config libplacebo).
#
# Not on macOS: both are Vulkan-only there and the SDK ships no MoltenVK (see
# common/ffmpeg-features.macos); macOS gets VideoToolbox/CoreImage filters instead.

# The C++ runtime the target compiler links by default, as a linker flag.
# libplacebo is C but its glslang bridge is C++; ffmpeg's configure link-tests
# libplacebo with the C driver, so the runtime has to be spelled out in
# libplacebo.pc's Libs.private. The SDK clangs default to libc++ (Linux/llvm.sh
# sets CLANG_DEFAULT_CXX_STDLIB, llvm-mingw only has libc++); a distro clang may
# default to libstdc++ -- ask the compiler rather than assume.
_md_cxx_runtime_flag() {
  local out
  out=$(echo 'int main(){}' | "${CXX:-clang++}" -x c++ - -o /dev/null -### 2>&1 || true)
  if echo "$out" | grep -q -- '-lc++'; then echo "-lc++"
  elif echo "$out" | grep -q -- '-lstdc++'; then echo "-lstdc++"
  else
    # -### output is not always parseable (e.g. some cross wrappers); probe by
    # linking instead.
    if echo 'int main(){}' | "${CXX:-clang++}" -x c++ - -o /dev/null -stdlib=libc++ >/dev/null 2>&1; then
      echo "-lc++"
    else
      echo "-lstdc++"
    fi
  fi
}

# A pinned meson for libplacebo. The SDK's own MESON_VERSION (0.61, a
# core-hash input via pipewire) predates libplacebo's floor, and the build
# images vary (AlmaLinux 9 ships 0.63, MSYS2 tracks upstream). meson is pure
# python and runs straight from its source tarball, so pin one and run that:
# no install, no interaction with whatever meson the image has. The pin must
# run on the image's interpreter: the Linux image has Python 3.9, so
# MESON_GPU_VERSION stays on a release that accepts it (see versions.sh).
_md_meson_gpu() {
  local src="$MEDIA_DEPS_SRC/meson-$MESON_GPU_VERSION"
  if [[ ! -f "$src/meson.py" ]]; then
    _md_fetch_tar "meson-$MESON_GPU_VERSION" 1 \
      "https://github.com/mesonbuild/meson/releases/download/$MESON_GPU_VERSION/meson-$MESON_GPU_VERSION.tar.gz" \
      || return 1
  fi
  # Newest interpreter around, then whatever python3 is; MSYS2's mingw python
  # ships python3.exe as well, but be safe about it.
  local py="${PYTHON3:-}" candidate
  if [[ -z "$py" ]]; then
    for candidate in python3.13 python3.12 python3.11 python3.10 python3 python; do
      if command -v "$candidate" >/dev/null 2>&1; then py=$candidate; break; fi
    done
  fi
  [[ -n "$py" ]] || { echo "media-deps: no python for meson" >&2; return 1; }
  "$py" "$src/meson.py" "$@"
}

_md_build_glslang() {   # SPIR-V compiler: the `glslang` binary for ffmpeg, static libs for libplacebo
  _md_clone glslang "$GLSLANG_VERSION" https://github.com/KhronosGroup/glslang
  _md_cmake_flags
  rm -rf "$(_md_build_dir glslang)"
  # ENABLE_OPT=OFF: the optimizer needs SPIRV-Tools + SPIRV-Headers checked out
  # into External/ (update_glslang_sources.py); neither ffmpeg's shader build
  # (no -Os unless configured --enable-small) nor libplacebo needs it.
  # ENABLE_HLSL=OFF: GLSL only. No tests, no PCH (PCH fights ccache).
  cmake -S "$MEDIA_DEPS_SRC/glslang" -B "$(_md_build_dir glslang)" "${MD_CMAKE_FLAGS[@]}" \
    -DENABLE_OPT=OFF -DENABLE_HLSL=OFF -DENABLE_GLSLANG_BINARIES=ON \
    -DGLSLANG_TESTS=OFF -DGLSLANG_ENABLE_INSTALL=ON -DENABLE_PCH=OFF \
    -DBUILD_EXTERNAL=OFF -DENABLE_SPIRV=ON
  cmake --build "$(_md_build_dir glslang)"
  cmake --install "$(_md_build_dir glslang)"
  # The binary is what ffmpeg.sh passes as --glslc; refuse to continue if the
  # install did not produce one rather than let configure fall back to probing
  # PATH (which is how the filters went missing in the first place).
  local exe="$MEDIA_DEPS_PREFIX/bin/glslang"
  [[ -x "$exe" || -x "$exe.exe" ]] || { echo "media-deps: glslang binary missing after install" >&2; return 1; }
}

_md_build_libplacebo() {   # ffmpeg's `libplacebo` filter (needs Vulkan + glslang)
  _md_clone libplacebo "$LIBPLACEBO_VERSION" https://github.com/haasn/libplacebo \
                                             https://code.videolan.org/videolan/libplacebo.git
  # The 3rdparty/ submodules are build-time only: jinja + markupsafe + glad are
  # python used by the shader/GL code generators, fast_float is header-only,
  # Vulkan-Headers pins the vk.xml registry the generators must agree with (the
  # meson build forces that copy whenever the directory exists). None of them
  # ends up in the installed library.
  ( cd "$MEDIA_DEPS_SRC/libplacebo"
    $GIT submodule update --init --depth 1 \
      3rdparty/jinja 3rdparty/markupsafe 3rdparty/glad 3rdparty/fast_float 3rdparty/Vulkan-Headers \
    || $GIT submodule update --init \
      3rdparty/jinja 3rdparty/markupsafe 3rdparty/glad 3rdparty/fast_float 3rdparty/Vulkan-Headers
  )
  rm -rf "$(_md_build_dir libplacebo)"
  local prefix; prefix="$(_md_native_prefix)"
  local cxxrt; cxxrt="$(_md_cxx_runtime_flag)"
  # find_library for the static glslang pieces searches the compiler's library
  # dirs (LIBRARY_PATH included) plus -Dvulkan-sdk/lib; the header check needs
  # the include dir. Passed through the environment meson reads at setup.
  #  vk-proc-addr=disabled : we never link the Vulkan loader (see the vulkan.pc
  #                          note in build-media-deps.sh); ffmpeg hands
  #                          libplacebo its get_proc_addr.
  #  opengl/d3d11 disabled : ffmpeg only uses the Vulkan backend.
  #  lcms/libdovi/xxhash/unwind disabled: each would be one more static dep to
  #                          carry into every score binary for no filter.
  CPPFLAGS="-I$prefix/include ${CPPFLAGS:-}" \
  CFLAGS="-I$prefix/include ${CFLAGS:-}" \
  CXXFLAGS="-I$prefix/include ${CXXFLAGS:-}" \
  LDFLAGS="-L$prefix/lib ${LDFLAGS:-}" \
  LIBRARY_PATH="$prefix/lib${LIBRARY_PATH:+:$LIBRARY_PATH}" \
  _md_meson_gpu setup "$(_md_build_dir libplacebo)" "$MEDIA_DEPS_SRC/libplacebo" \
    --prefix="$MEDIA_DEPS_PREFIX" --libdir=lib \
    --buildtype=release --default-library=static --prefer-static \
    -Dvulkan=enabled -Dvk-proc-addr=disabled -Dvulkan-sdk="$prefix" \
    -Dglslang=enabled -Dshaderc=disabled \
    -Dopengl=disabled -Dgl-proc-addr=disabled -Dd3d11=disabled \
    -Dlcms=disabled -Dlibdovi=disabled -Dxxhash=disabled -Dunwind=disabled \
    -Ddemos=false -Dtests=false -Dbench=false \
    ${MD_MESON_EXTRA_FLAGS:+"${MD_MESON_EXTRA_FLAGS[@]}"} \
    || { echo "media-deps: libplacebo: meson setup failed" >&2; return 1; }
  ninja -C "$(_md_build_dir libplacebo)" || return 1
  ninja -C "$(_md_build_dir libplacebo)" install || return 1

  # ffmpeg probes with `pkg-config --static --libs libplacebo` and link-tests
  # pl_vulkan_create with the C driver, so Libs.private must carry everything
  # the static archive needs: the glslang libraries and the C++ runtime. meson
  # lists the find_library() results itself; the runtime it cannot know about.
  local pc="$MEDIA_DEPS_PREFIX/lib/pkgconfig/libplacebo.pc"
  [[ -f "$pc" ]] || { echo "media-deps: libplacebo.pc missing after install" >&2; return 1; }
  if ! grep -q '^Libs.private:' "$pc"; then
    echo 'Libs.private:' >> "$pc"
  fi
  # The glslang set, once, in static link order (SPIRV needs MachineIndependent
  # and GenericCodeGen after it), then the C++ runtime and libm. Idempotent so a
  # re-run of the recipe does not grow the line.
  if ! grep -q -- '-lMachineIndependent' "$pc"; then
    sed -i.bak -e 's|^Libs.private:\(.*\)$|Libs.private:\1 -lglslang-default-resource-limits -lglslang -lSPIRV -lMachineIndependent -lGenericCodeGen -lOSDependent|' "$pc"
  fi
  local want
  for want in "$cxxrt" -lm; do
    grep -q -- " $want" "$pc" || sed -i.bak -e "s|^Libs.private:.*|& $want|" "$pc"
  done
  rm -f "$pc.bak"
  # ffmpeg 9's floor; failing here is clearer than "libplacebo not found using pkg-config".
  local v; v=$(grep '^Version:' "$pc" | awk '{print $2}')
  echo "media-deps: libplacebo $v installed ($(grep '^Libs.private' "$pc"))"
}
