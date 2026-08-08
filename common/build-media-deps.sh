#!/bin/bash
# Shared recipes for ffmpeg's media dependencies: codecs, the SRT protocol, and
# the two hardware-acceleration header packages.
#
# Everything lands in ONE prefix ($MEDIA_DEPS_PREFIX) with .pc files, and
# nothing here is ffmpeg-specific. That is deliberate: a gstreamer build needs
# the same codecs (x264/x265/dav1d/...) and the same hwaccel headers (ffnvcodec,
# vulkan), and should get them by pointing PKG_CONFIG_PATH at this prefix rather
# than by growing a second copy of these recipes.
#
# Usage, from <platform>/media-deps.sh:
#   source ./common.sh
#   export MEDIA_DEPS_PREFIX=...      # install prefix (default: $INSTALL_PREFIX/sysroot)
#   export MEDIA_DEPS_LIST="..."      # which recipes to run, in order
#   source ../common/build-media-deps.sh
#   build_media_deps
#
# On the hwaccel headers: ffnvcodec and Vulkan-Headers install headers ONLY.
# ffmpeg dlopen()s libcuda / libnvcuvid / libnvidia-encode / libvulkan.so.1 /
# vulkan-1.dll at runtime and degrades gracefully when they are absent, so
# enabling NVDEC/NVENC/CUDA and Vulkan Video costs nothing in portability: the
# produced binaries have exactly the same DT_NEEDED / import table as before.
# Verify with `ldd`/`dumpbin /dependents` after a build -- if libcuda or
# libvulkan shows up there, something linked them for real and that IS a
# regression for "runs on every machine".

source ../common/versions.sh

: "${MEDIA_DEPS_PREFIX:=$INSTALL_PREFIX/sysroot}"
: "${MEDIA_DEPS_SRC:=$PWD}"
: "${NPROC:=4}"
: "${GIT:=git}"   # Linux/CentOS pins this to /usr/bin/git; elsewhere it is unset

_md_msg() { echo "== media-deps: $*"; }

# The prefix in the form the NATIVE toolchain understands. On MSYS the shell
# path (/c/...) is meaningless to the mingw binaries: x264's `make install`
# copies the archive fine and then dies in llvm-ranlib.exe with "unable to load
# '/c/.../libx264.a'". cmake gets this via MEDIA_DEPS_PREFIX_CMAKE already;
# autotools recipes need it too. Identical to MEDIA_DEPS_PREFIX everywhere else.
_md_native_prefix() { echo "${MEDIA_DEPS_PREFIX_CMAKE:-$MEDIA_DEPS_PREFIX}"; }

# Any path in the form the native toolchain understands. cygpath -m yields
# "d:/tmp/..." on MSYS; everywhere else the path is already native and this is
# an echo.
_md_native_path() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else echo "$1"; fi
}

# Build directory for a dep. $MD_BUILD_TAG keeps configurations apart: macOS
# builds the whole set once per architecture slice, and a shared build dir there
# is silently wrong -- cmake reads CFLAGS from the environment only on the FIRST
# configure, so slice 2 re-used slice 1's cached "-arch x86_64" and produced
# accidentally-fat archives (or, where a project assigns CMAKE_C_FLAGS itself,
# the wrong arch outright).
_md_build_dir() { echo "$1-build${MD_BUILD_TAG:-}"; }

# Marker files, not "is the .a there" probes: several of these install multiple
# artifacts and a half-finished build would otherwise look complete.
_md_done()      { [[ -f "$MEDIA_DEPS_PREFIX/.media-deps/$1" ]]; }
_md_mark_done() { mkdir -p "$MEDIA_DEPS_PREFIX/.media-deps"; touch "$MEDIA_DEPS_PREFIX/.media-deps/$1"; }

_md_clone() {  # name ref url [url...]
  # ref comes BEFORE the urls so the last argument never has to be addressed:
  # macOS's /bin/bash is 3.2, where ${a[-1]} is "bad array subscript".
  local name=$1 ref=$2; shift 2
  local urls=("$@")

  # Test for a real repository, not just the directory. A leftover empty or
  # half-cloned dir would otherwise make this skip the clone and then fail in
  # the checkout with "not a git repository" -- and stay wedged on every later
  # run. Easy to hit on Windows, where `rm -rf` routinely empties a directory
  # but cannot remove it while something still holds a handle.
  if [[ -d "$MEDIA_DEPS_SRC/$name" && ! -d "$MEDIA_DEPS_SRC/$name/.git" ]]; then
    echo "media-deps: $name: directory exists but is not a git clone, replacing it" >&2
    rm -rf "${MEDIA_DEPS_SRC:?}/$name"
  fi
  if [[ ! -d "$MEDIA_DEPS_SRC/$name/.git" ]]; then
    # Try each URL in turn. code.videolan.org hosts both dav1d and x264 and has
    # gone down for hours at a time (observed 2026-08-08 from two continents),
    # which is enough to take out every platform's media build at once.
    # No --depth: several pins are branch SHAs rather than tags, and a shallow
    # clone cannot check out an arbitrary commit.
    local url ok=0
    for url in "${urls[@]}"; do
      if $GIT clone --quiet "$url" "$MEDIA_DEPS_SRC/$name"; then ok=1; break; fi
      echo "media-deps: $name: $url unreachable, trying the next mirror" >&2
      rm -rf "$MEDIA_DEPS_SRC/$name"
    done
    if [[ $ok -eq 0 ]]; then
      echo "media-deps: $name: every mirror failed (${urls[*]})" >&2
      return 1
    fi
  fi
  ( cd "$MEDIA_DEPS_SRC/$name"
    # The checkout can legitimately fail against an existing tree: the self-hosted
    # runners keep the source dir between runs, so after a version bump the new
    # ref simply is not in the local clone yet. Fetch and retry rather than
    # failing the build (or, worse, silently building the previous pin).
    #
    # Re-point origin first. When a dep moves to a different repo -- e.g.
    # SVT-JPEG-XS and x264 moving to the ossia mirrors -- a cached clone still
    # has the OLD remote, so fetching "origin" can never produce the new ref and
    # the build dies with "unable to read tree <sha>".
    $GIT checkout --quiet "$ref" 2>/dev/null || {
      for url in "${urls[@]}"; do
        $GIT remote set-url origin "$url" 2>/dev/null || true
        $GIT fetch --quiet --tags --force origin 2>/dev/null || continue
        $GIT checkout --quiet "$ref" 2>/dev/null && break
      done
      $GIT checkout --quiet "$ref"
    }
    # For a branch pin (AMF tracks a tag today, but x264 is a branch SHA and a
    # future pin may be a branch name) checkout alone leaves the old commit.
    $GIT reset --quiet --hard "$ref" -- 2>/dev/null || true )
}

_md_fetch_tar() {  # name stripdir url [url...]
  # Some deps have no git upstream worth using -- lame lives on SourceForge and
  # nowhere else official. Same mirror-list shape as _md_clone: the ossia
  # release first, upstream as fallback.
  local name=$1 strip=$2; shift 2
  local urls=("$@")
  [[ -d "$MEDIA_DEPS_SRC/$name" ]] && return 0

  local url tmp="$MEDIA_DEPS_SRC/.$name.tar"
  for url in "${urls[@]}"; do
    if curl -fksSL -o "$tmp" "$url"; then
      rm -rf "$MEDIA_DEPS_SRC/$name.tmp"; mkdir -p "$MEDIA_DEPS_SRC/$name.tmp"
      # -z/-j named explicitly, never -a: bsdtar rejects -a in extract mode on
      # macOS 15 (see common/clone-openssl.sh).
      if tar xzf "$tmp" -C "$MEDIA_DEPS_SRC/$name.tmp" --strip-components="$strip"; then
        rm -f "$tmp"; mv "$MEDIA_DEPS_SRC/$name.tmp" "$MEDIA_DEPS_SRC/$name"; return 0
      fi
      rm -rf "$MEDIA_DEPS_SRC/$name.tmp"
    fi
    echo "media-deps: $name: $url unusable, trying the next mirror" >&2
  done
  echo "media-deps: $name: every mirror failed (${urls[*]})" >&2
  return 1
}

# cmake flags every dep here wants. $CMAKE_ADDITIONAL_FLAGS carries the macOS
# deployment target / sysroot / Homebrew-ignore set and is empty elsewhere.
_md_cmake_flags() {
  MD_CMAKE_FLAGS=(
    -GNinja
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    -DCMAKE_INSTALL_PREFIX="${MEDIA_DEPS_PREFIX_CMAKE:-$MEDIA_DEPS_PREFIX}"
    # Pin the libdir. CMake defaults to lib64 on RedHat-family distros, which
    # would scatter the prefix -- cmake deps in sysroot/lib64, meson/autotools
    # ones in sysroot/lib -- and ffmpeg then fails with "opus not found using
    # pkg-config" because only one of the two is on PKG_CONFIG_PATH.
    -DCMAKE_INSTALL_LIBDIR=lib
    # Pass the Apple arch as a CACHE variable. CMake does NOT read
    # CMAKE_OSX_ARCHITECTURES from the environment, and relying on the -arch in
    # $CFLAGS is not enough either: a project that assigns CMAKE_C_FLAGS
    # wholesale drops it. SVT-JPEG-XS does exactly that, so its "x86_64h" slice
    # came out as x86_64 and lipo refused the merge ("have the same
    # architectures (x86_64)"). Empty and harmless off macOS.
    ${CMAKE_OSX_ARCHITECTURES:+-DCMAKE_OSX_ARCHITECTURES=$CMAKE_OSX_ARCHITECTURES}
    ${CMAKE_ADDITIONAL_FLAGS:-}
  )
}

# --------------------------------------------------------------- hwaccel ----
_md_build_nvcodec_headers() {   # headers only; ffmpeg dlopens the driver libraries
  _md_clone nv-codec-headers "$NVCODEC_VERSION" https://github.com/FFmpeg/nv-codec-headers
  make -C "$MEDIA_DEPS_SRC/nv-codec-headers" PREFIX="$MEDIA_DEPS_PREFIX" install
}

_md_build_amf_headers() {   # headers only; ffmpeg dlopens amfrt64.dll / libamfrt64.so
  # AMD encode+decode (h264/hevc/av1/vp9). ffmpeg's only probe is a
  # check_cpp_condition on AMF/core/Version.h -- nothing is linked, and
  # EXTRALIBS stays empty. Upstream ships no install rule, so copy the public
  # include tree to the AMF/ prefix ffmpeg's #include <AMF/core/...> expects.
  _md_clone AMF "$AMF_VERSION" https://github.com/GPUOpen-LibrariesAndSDKs/AMF
  mkdir -p "$MEDIA_DEPS_PREFIX/include/AMF"
  cp -r "$MEDIA_DEPS_SRC/AMF/amf/public/include/." "$MEDIA_DEPS_PREFIX/include/AMF/"
}

_md_build_vulkan_headers() {   # headers only; ffmpeg dlopens the Vulkan loader
  _md_clone Vulkan-Headers "$VULKAN_HEADERS_VERSION" https://github.com/KhronosGroup/Vulkan-Headers
  _md_cmake_flags
  rm -rf "$(_md_build_dir vulkan-headers)"
  cmake -S "$MEDIA_DEPS_SRC/Vulkan-Headers" -B "$(_md_build_dir vulkan-headers)" "${MD_CMAKE_FLAGS[@]}"
  cmake --install "$(_md_build_dir vulkan-headers)"
  # Vulkan-Headers ships no .pc. ffmpeg's probe is header-only
  # (check_pkg_config_header_only vulkan "vulkan >= 1.3.277"), so a Cflags-only
  # file is enough and must NOT name a library -- we do not link the loader.
  mkdir -p "$MEDIA_DEPS_PREFIX/lib/pkgconfig"
  cat > "$MEDIA_DEPS_PREFIX/lib/pkgconfig/vulkan.pc" <<EOF
prefix=$MEDIA_DEPS_PREFIX
includedir=\${prefix}/include

Name: Vulkan-Headers
Description: Vulkan headers only -- the loader is dlopened, never linked
Version: ${VULKAN_HEADERS_VERSION#vulkan-sdk-}
Cflags: -I\${includedir}
EOF
}

# ---------------------------------------------------------------- codecs ----
_md_build_dav1d() {   # AV1 decoding; ffmpeg's native AV1 decoder is far slower
  # github.com/videolan/dav1d is VideoLAN's own mirror and carries the release
  # tags, so it goes first; code.videolan.org is the fallback, not the primary.
  _md_clone dav1d "$DAV1D_VERSION" https://github.com/videolan/dav1d \
                                  https://code.videolan.org/videolan/dav1d.git
  rm -rf "$(_md_build_dir dav1d)"
  # Not $MESON_COMMON_FLAGS: that array carries -Dglib/-Dgobject/-Dicu/-Ddocs,
  # which are pipewire's options, and meson hard-errors on options a project
  # does not define.
  meson setup "$(_md_build_dir dav1d)" "$MEDIA_DEPS_SRC/dav1d" \
    --prefix="$MEDIA_DEPS_PREFIX" --libdir=lib \
    --buildtype=release --default-library=static \
    -Denable_tools=false -Denable_tests=false \
    ${MD_MESON_EXTRA_FLAGS:+"${MD_MESON_EXTRA_FLAGS[@]}"}
  ninja -C "$(_md_build_dir dav1d)"
  ninja -C "$(_md_build_dir dav1d)" install
}

_md_build_x264() {
  # ossia/x264 first: code.videolan.org is x264's only upstream and it was down
  # for hours on 2026-08-08, taking out every platform's media build at once.
  # (github.com/mirror/x264 is NOT a usable fallback -- last commit 2024-02, and
  # it does not contain $X264_VERSION.)
  _md_clone x264 "$X264_VERSION" https://github.com/ossia/x264 \
                                 https://code.videolan.org/videolan/x264.git
  # In-tree, unlike the other recipes: x264's configure refuses an out-of-tree
  # build as soon as a config.h/x264_config.h exists in the source dir, so any
  # earlier in-tree build (ours or a distro's) poisons it. distclean first so a
  # re-run on a runner that keeps its source dir starts from a clean state.
  ( cd "$MEDIA_DEPS_SRC/x264"
    # Delete the generated files directly instead of "make distclean". On MSYS,
    # `make` is the native C:\gnu\bin\make.exe and running it over x264's
    # Makefile HANGS indefinitely (reproduced: distclean times out, while
    # ./configure on the same tree finishes fine). There is nothing to clean on
    # a fresh clone anyway, and this needs no make at all.
    rm -f config.mak config.h x264_config.h x264.pc x264.def
    ./configure --prefix="$(_md_native_prefix)" \
      --enable-static --enable-pic --disable-cli \
      --disable-opencl --disable-avs --disable-swscale --disable-lavf --disable-ffms \
      ${MD_X264_EXTRA_FLAGS:+"${MD_X264_EXTRA_FLAGS[@]}"}
    make -j"$NPROC"
    make install )
}

_md_build_x265() {
  # ossia/x265 mirrors bitbucket; videolan/x265 on github is stale (stops at 3.4).
  _md_clone x265 "$X265_VERSION" https://github.com/ossia/x265 \
                                 https://bitbucket.org/multicoreware/x265_git.git
  _md_cmake_flags
  # x265's CMakeLists lives in source/, not at the repo root.
  rm -rf "$(_md_build_dir x265)"
  cmake -S "$MEDIA_DEPS_SRC/x265/source" -B "$(_md_build_dir x265)" "${MD_CMAKE_FLAGS[@]}" \
    -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DENABLE_PIC=ON
  cmake --build "$(_md_build_dir x265)"
  cmake --install "$(_md_build_dir x265)"
}

_md_build_opus() {
  _md_clone opus "$OPUS_VERSION" https://github.com/xiph/opus
  _md_cmake_flags
  rm -rf "$(_md_build_dir opus)"
  cmake -S "$MEDIA_DEPS_SRC/opus" -B "$(_md_build_dir opus)" "${MD_CMAKE_FLAGS[@]}" \
    -DOPUS_BUILD_PROGRAMS=OFF -DOPUS_BUILD_TESTING=OFF
  cmake --build "$(_md_build_dir opus)"
  cmake --install "$(_md_build_dir opus)"
}

_md_build_vpx() {
  # VP8/VP9 SOFTWARE encoding. Without it the webm muxer is unusable on a
  # machine with no suitable GPU: ffmpeg decodes VP8/VP9 natively and dav1d
  # covers AV1 decode, but the only *encoders* we would otherwise ship for a
  # webm are av1_nvenc / av1_amf / av1_vulkan, i.e. hardware-only.
  _md_clone libvpx "$VPX_VERSION" https://github.com/webmproject/libvpx \
                                https://chromium.googlesource.com/webm/libvpx
  # Out-of-tree, but configure must be reached by a NATIVE path. libvpx bakes
  # the source path into the generated Makefile, and build/make/configure.sh
  # canonicalises a relative "." to $(pwd) -- so an in-tree build does not help:
  # either way the path is the MSYS form (/d/tmp/...) and the native
  # mingw32-make then fails with "No rule to make target '/d/.../libs.mk'".
  # libvpx refuses an out-of-tree build when the SOURCE tree still holds a
  # previous configuration ("source directory already configured; run 'make
  # distclean' there first"), so clear those artefacts rather than running its
  # distclean -- the runners keep the source dir between runs, and on MSYS
  # invoking make over this Makefile is what wedged x264.
  rm -f "$MEDIA_DEPS_SRC"/libvpx/{config.mk,config.log,libvpx.pc,vpx_config.h,vpx_config.asm,vpx_version.h} \
        "$MEDIA_DEPS_SRC"/libvpx/{vpx_scale_rtcd.h,vpx_dsp_rtcd.h,vp8_rtcd.h,vp9_rtcd.h} 2>/dev/null || true
  rm -rf "$(_md_build_dir vpx)"; mkdir -p "$(_md_build_dir vpx)"
  ( cd "$(_md_build_dir vpx)"
    "$(_md_native_path "$MEDIA_DEPS_SRC/libvpx")/configure" --prefix="$(_md_native_prefix)" \
      --enable-static --disable-shared --enable-pic \
      --enable-vp8 --enable-vp9 --disable-examples --disable-tools \
      --disable-docs --disable-unit-tests --enable-vp9-highbitdepth \
      ${MD_VPX_EXTRA_FLAGS:+"${MD_VPX_EXTRA_FLAGS[@]}"}
    make -j"$NPROC"
    make install )
}

_md_build_webp() {
  # ffmpeg gains WebP *encoding* (it already decodes WebP natively).
  #
  # This is also the library qtimageformats needs for its webp plugin. Qt builds
  # its own bundled copy unless configured with -system-webp, so as long as
  # common/qtfeatures does not say that, a fully static score links TWO copies of
  # libwebp. Point Qt at this one before assuming the duplicate is harmless.
  _md_clone libwebp "$WEBP_VERSION" https://github.com/webmproject/libwebp \
                                  https://chromium.googlesource.com/webm/libwebp
  _md_cmake_flags
  rm -rf "$(_md_build_dir webp)"
  cmake -S "$MEDIA_DEPS_SRC/libwebp" -B "$(_md_build_dir webp)" "${MD_CMAKE_FLAGS[@]}" \
    -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_DWEBP=OFF \
    -DWEBP_BUILD_GIF2WEBP=OFF -DWEBP_BUILD_IMG2WEBP=OFF -DWEBP_BUILD_VWEBP=OFF \
    -DWEBP_BUILD_WEBPINFO=OFF -DWEBP_BUILD_WEBPMUX=OFF -DWEBP_BUILD_EXTRAS=OFF
  cmake --build "$(_md_build_dir webp)"
  cmake --install "$(_md_build_dir webp)"
}

_md_build_snappy() {
  # Hap encoding (ffmpeg's --enable-libsnappy). Linux and MSYS already build
  # snappy in their CORE stage via zlib.sh; macOS has no equivalent, so it is a
  # media-stage recipe there. Same fork/pin as common/clone-zlib.sh so all three
  # platforms ship the same snappy.
  _md_clone snappy "$SNAPPY_VERSION" https://github.com/jcelerier/snappy
  _md_cmake_flags
  rm -rf "$(_md_build_dir snappy)"
  cmake -S "$MEDIA_DEPS_SRC/snappy" -B "$(_md_build_dir snappy)" "${MD_CMAKE_FLAGS[@]}" \
    -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DSNAPPY_INSTALL=ON
  cmake --build "$(_md_build_dir snappy)"
  cmake --install "$(_md_build_dir snappy)"
  # snappy ships no .pc; ffmpeg's libsnappy probe is a plain link check, but
  # gstreamer and other consumers expect one.
  mkdir -p "$MEDIA_DEPS_PREFIX/lib/pkgconfig"
  cat > "$MEDIA_DEPS_PREFIX/lib/pkgconfig/snappy.pc" <<EOF
prefix=$MEDIA_DEPS_PREFIX
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: snappy
Description: Snappy compression
Version: $SNAPPY_VERSION
Libs: -L\${libdir} -lsnappy
Cflags: -I\${includedir}
EOF
}

_md_build_svtjpegxs() {   # JPEG XS encode+decode, native in ffmpeg 9 as libsvtjpegxs
  # ossia/SVT-JPEG-XS carries one patch on top of the upstream pin: upstream's
  # CMake hardcodes x86 (unconditional ASM_NASM + -DARCH_X86_64=1) so it cannot
  # configure on aarch64 at all, even though the C sources already have the
  # non-x86 fallback. See the note on SVTJPEGXS_VERSION in common/versions.sh.
  _md_clone SVT-JPEG-XS "$SVTJPEGXS_VERSION" https://github.com/ossia/SVT-JPEG-XS \
                                             https://github.com/OpenVisualCloud/SVT-JPEG-XS
  _md_cmake_flags
  rm -rf "$(_md_build_dir svtjpegxs)"
  cmake -S "$MEDIA_DEPS_SRC/SVT-JPEG-XS" -B "$(_md_build_dir svtjpegxs)" "${MD_CMAKE_FLAGS[@]}" \
    -DBUILD_APPS=OFF -DBUILD_TESTING=OFF \
    ${MD_SVTJPEGXS_EXTRA_FLAGS:+"${MD_SVTJPEGXS_EXTRA_FLAGS[@]}"}
  cmake --build "$(_md_build_dir svtjpegxs)"
  cmake --install "$(_md_build_dir svtjpegxs)"
}

_md_build_mp3lame() {
  # MP3 encoding. ffmpeg has NO native MP3 encoder -- without this, score cannot
  # export MP3 at all. SourceForge is lame's only home, so the ossia release
  # mirrors the tarball.
  _md_fetch_tar lame 1 \
    https://github.com/ossia/sdk/releases/download/sdk36/lame-$LAME_VERSION.tar.gz \
    https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.*}/lame-$LAME_VERSION.tar.gz
  ( cd "$MEDIA_DEPS_SRC/lame"
    rm -f config.status
    ./configure --prefix="$(_md_native_prefix)" \
      --enable-static --disable-shared --disable-frontend --disable-gtktest --with-pic \
      ${MD_LAME_EXTRA_FLAGS:+"${MD_LAME_EXTRA_FLAGS[@]}"}
    make -j"$NPROC"
    make install )
}

_md_build_xml2() {
  # Unlocks ffmpeg's dash and imf demuxers (dash_demuxer_deps="libxml2"), i.e.
  # DASH playback -- odd to have network enabled without it.
  _md_clone libxml2 "$LIBXML2_VERSION" https://github.com/GNOME/libxml2 \
                                       https://gitlab.gnome.org/GNOME/libxml2.git
  _md_cmake_flags
  # Everything off but the parser: ffmpeg only needs xmlCheckVersion and the
  # tree/reader API. Leaving zlib/lzma on would put -lz -llzma in libxml-2.0.pc
  # and make ffmpeg's --static pkg-config resolution depend on them.
  rm -rf "$(_md_build_dir xml2)"
  cmake -S "$MEDIA_DEPS_SRC/libxml2" -B "$(_md_build_dir xml2)" "${MD_CMAKE_FLAGS[@]}" \
    -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_TESTS=OFF -DLIBXML2_WITH_PROGRAMS=OFF \
    -DLIBXML2_WITH_ICONV=OFF -DLIBXML2_WITH_ICU=OFF \
    -DLIBXML2_WITH_ZLIB=OFF -DLIBXML2_WITH_LZMA=OFF
  cmake --build "$(_md_build_dir xml2)"
  cmake --install "$(_md_build_dir xml2)"
}

# -------------------------------------------------------------- protocol ----
_md_build_srt() {   # SRT ingress/egress. Encryption comes from the SDK's openssl.
  _md_clone srt "$SRT_VERSION" https://github.com/Haivision/srt
  _md_cmake_flags
  rm -rf "$(_md_build_dir srt)"
  cmake -S "$MEDIA_DEPS_SRC/srt" -B "$(_md_build_dir srt)" "${MD_CMAKE_FLAGS[@]}" \
    -DENABLE_SHARED=OFF -DENABLE_STATIC=ON \
    -DENABLE_APPS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_UNITTESTS=OFF \
    ${MD_SRT_EXTRA_FLAGS:+"${MD_SRT_EXTRA_FLAGS[@]}"}
  cmake --build "$(_md_build_dir srt)"
  cmake --install "$(_md_build_dir srt)"
}

# ----------------------------------------------------------------- driver ---
build_media_deps() {
  local list="${MEDIA_DEPS_LIST:?set MEDIA_DEPS_LIST}"
  mkdir -p "$MEDIA_DEPS_PREFIX/lib/pkgconfig"
  # Each recipe both consumes (srt needs openssl) and produces .pc files here.
  export PKG_CONFIG_PATH="$MEDIA_DEPS_PREFIX/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

  local dep
  for dep in $list; do
    if _md_done "$dep"; then _md_msg "$dep already built"; continue; fi
    _md_msg "building $dep"
    if ! "_md_build_$dep"; then
      # Explicit, because relying on `set -e` here has twice let a failed recipe
      # through and left ffmpeg to fail much later with a confusing
      # "<codec> not found using pkg-config".
      echo "media-deps: FAILED to build '$dep'" >&2
      return 1
    fi
    _md_mark_done "$dep"
  done

  _md_msg "installed into $MEDIA_DEPS_PREFIX"
  ls "$MEDIA_DEPS_PREFIX/lib/pkgconfig" || true
}
