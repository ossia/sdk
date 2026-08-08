export SDL_VERSION=2.32.10
export FFMPEG_VERSION=9.0

# ---------------------------------------------------------------------------
# ffmpeg media dependencies (common/build-media-deps.sh).
#
# Installed into the platform's shared dep prefix with .pc files, NOT into
# ffmpeg's own prefix: a later gstreamer build needs the same codecs and the
# same hardware-acceleration headers, and should find them by pointing
# PKG_CONFIG_PATH at the one place they live.
#
# Both hwaccel entries are HEADERS ONLY. ffmpeg dlopen()s libcuda / libnvcuvid /
# libnvidia-encode / libvulkan at runtime, so enabling them adds no link-time or
# runtime dependency -- `ldd` on the result is unchanged. That is what makes
# hardware decoding safe to turn on in binaries that must run everywhere.
export NVCODEC_VERSION=n13.0.19.1          # ffmpeg 9 needs ffnvcodec >= 12.1.14.0
export VULKAN_HEADERS_VERSION=vulkan-sdk-1.4.350.0   # ffmpeg 9 needs vulkan >= 1.3.277
# AMD AMF headers. ffmpeg 9 requires AMF_FULL_VERSION >= 1.5.2.0, and v1.5.2 is
# exactly that -- do not pin lower, configure rejects it.
export AMF_VERSION=v1.5.2
export DAV1D_VERSION=1.5.4
# x264 publishes no tags; this is refs/heads/stable.
export X264_VERSION=b35605ace3ddf7c1a5d67a2eb553f034aef41d55
export X265_VERSION=4.2
export OPUS_VERSION=v1.6.1
export SRT_VERSION=v1.5.6
# Hap encoding. Same fork/pin common/clone-zlib.sh uses for the Linux/MSYS core
# stage; macOS has no core zlib.sh, so it builds snappy as a media dep instead.
export SNAPPY_VERSION=ossia-2025-03-31
# VP8/VP9 software encoding -- the webm muxer has no usable software video
# encoder without it (see common/build-media-deps.sh).
export VPX_VERSION=v1.16.0
# Also what qtimageformats' webp plugin wants; see the note in
# common/build-media-deps.sh about -system-webp vs Qt's bundled copy.
export WEBP_VERSION=v1.6.0
# MP3 encoding: ffmpeg ships no native MP3 encoder at all. SourceForge is lame's
# only home, so the tarball is mirrored on the ossia sdk36 release
# (sha256 ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e).
export LAME_VERSION=3.100
# ffmpeg's dash and imf demuxers are gated on libxml2.
export LIBXML2_VERSION=v2.15.3
# ossia/SVT-JPEG-XS branch ossia-arm64 = upstream main @ 8056642 (0.10.0, the
# minimum ffmpeg 9 accepts; their newest TAG is only v0.9.0) plus one commit
# making the build work off x86. Upstream unconditionally does
# enable_language(ASM_NASM) + add_definitions(-DARCH_X86_64=1), so aarch64 could
# not configure at all -- which would have cost us JPEG XS on Apple Silicon,
# Linux aarch64 and Windows ARM. Verified: x86 unit tests still 11997/11997, and
# the aarch64 C-only build is bit-exact with the x86 SIMD build. The branch also
# turns upstream's unconditional -flto off: with it every archive member is LLVM
# bitcode, which ld can only consume from a link targeting that exact arch, so
# the library could not be linked into a fat (x86_64 + x86_64h) macOS binary,
# and lets -DSVT_JPEGXS_ARCH_X86 override the arch auto-detection, which is what
# makes a cross build to x86_64 from an arm64 host possible at all.
export SVTJPEGXS_VERSION=9cbff356bc6de08462cbf4a6b916b940cedfca53
# emsdk pin for the WASM SDK. Must match Qt's QT_EMCC_RECOMMENDED_VERSION for
# $QT_VERSION (qtbase/cmake/QtPublicWasmToolchainHelpers.cmake); still 5.0.5 on
# the 6.12 branch. Re-check this when moving QT_VERSION.
export EMSDK_VERSION=5.0.5
export FFTW_VERSION=3.3.11
# Faust does tag releases (2.85.9 is the latest) but the SDK tracks master-dev:
# the stable tags lag it by a month or so, and the fixes in FAUST_PRS are written
# against master-dev. Full SHA, because a shallow clone can only fetch a commit
# by its full name.
export FAUST_VERSION=2e20dde10938821e68395f5e25e8414c6767f13e
# Unmerged fixes we carry, as grame-cncm/faust pull request numbers.
#  1281: std::less<CTree*> was specialized to order trees by serial(). libc++
#        rewrites std::less<T> to std::less<> on the container insert path, so
#        std::set<Tree>/std::map<Tree, T> end up built in address order and
#        queried in serial order; lookups then miss entries that are present and
#        the compiler recurses until its stack is gone. Intermittent, and it hit
#        223 of the 296 faust examples on libc++ (macOS, MSYS/CLANG64, WASM).
export FAUST_PRS="1281"
export LLVM_MINGW_VERSION=20260616
export LLVM_VERSION=llvmorg-22.1.8
export OPENSSL_VERSION=3.5.7
# qt5.git super-repo commit, not a tag: v6.12.0-beta1 is two months and 1171
# commits behind the 6.12 branch. A full SHA rather than a branch name keeps the
# build reproducible; github.com and code.qt.io both allow fetching one directly
# into a shallow clone, which is what clone-qt.sh and WASM/qt-deps.sh rely on.
# To bump: take the current tip of https://github.com/qt/qt5 refs/heads/6.12.
export QT_VERSION=02761a0550f53096f48e394cd8824c96b78eaa3d
export CMAKE_VERSION_SHORT=4.3
export CMAKE_VERSION=4.3.4
export PYTHON_VERSION=3.13.14
export MESON_VERSION=0.61.1
export PIPEWIRE_VERSION=1.6.7
# `extra` stage: prebuilt extension dependencies (see common/build-*.sh)
export ONNXRUNTIME_VERSION=1.27.0

# git 2.55 runs maintenance (gc / commit-graph) in the background after clone and
# fetch. On our many shallow clones it races the very next git command in the
# script -- two ways seen in CI, both on git-2.55 runners (macOS + Windows; the
# Linux container's git 2.54 is immune):
#   fatal: shallow file has changed since we read it        (during the Qt picks)
#   fatal: Unable to create '.../.git/index.lock': File exists   (during the llvm clone)
# Turn the background writers off globally, once, before any clone runs. This is
# sourced by every clone script (and each platform common.sh) ahead of its first
# git call, so it covers llvm/freetype/qt/... not just the Qt picks. Idempotent;
# skipped where git is absent. Not folded into the core hash (only the version
# pins above are), so this does not rotate the already-built cores.
if command -v git >/dev/null 2>&1; then
  git config --global gc.auto 0 || true
  git config --global maintenance.auto false || true
  git config --global fetch.writeCommitGraph false || true
fi

# In CI, clone shallow to cut clone time/bandwidth (LLVM and Qt history is huge).
# Local dev keeps full history. GitHub Actions exports CI=true on every runner;
# Linux/create-sdk.sh forwards CI into the build container.
if [[ -n "${CI:-}" ]]; then
  export SDK_CLONE_DEPTH="--depth 1"
  export SDK_SHALLOW_SUBMODULES="--shallow-submodules"
  # cherry-pick needs the change commit AND its parent, hence depth 2
  export SDK_FETCH_DEPTH="--depth 2"
else
  export SDK_CLONE_DEPTH=""
  export SDK_SHALLOW_SUBMODULES=""
  export SDK_FETCH_DEPTH=""
fi
