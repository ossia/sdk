export SDL_VERSION=2.32.10
export FFMPEG_VERSION=8.1
# emsdk pin for the WASM SDK. Must match Qt's QT_EMCC_RECOMMENDED_VERSION for
# $QT_VERSION (qtbase/cmake/QtPublicWasmToolchainHelpers.cmake); 6.12.0-beta1 -> 5.0.5.
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
export QT_VERSION=v6.12.0-beta1
export CMAKE_VERSION_SHORT=4.3
export CMAKE_VERSION=4.3.4
export PYTHON_VERSION=3.13.14
export MESON_VERSION=0.61.1
export PIPEWIRE_VERSION=1.6.7

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
