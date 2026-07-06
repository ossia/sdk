export SDL_VERSION=2.32.10
export FFMPEG_VERSION=8.1
# emsdk pin for the WASM SDK. Must match Qt's QT_EMCC_RECOMMENDED_VERSION for
# $QT_VERSION (qtbase/cmake/QtPublicWasmToolchainHelpers.cmake); 6.12.0-beta1 -> 5.0.5.
export EMSDK_VERSION=5.0.5
export FFTW_VERSION=3.3.11
export LLVM_MINGW_VERSION=20260616
export LLVM_VERSION=llvmorg-22.1.8
export OPENSSL_VERSION=3.5.7
export QT_VERSION=v6.12.0-beta1
export CMAKE_VERSION_SHORT=4.3
export CMAKE_VERSION=4.3.4
export PYTHON_VERSION=3.13.14
export MESON_VERSION=0.61.1
export PIPEWIRE_VERSION=1.6.7

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
