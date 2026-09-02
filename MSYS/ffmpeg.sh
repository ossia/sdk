#!/bin/bash -eu

source ./common.sh
source ../common/clone-ffmpeg.sh
source ../common/ffmpeg-features.sh

(
cd ffmpeg-$FFMPEG_VERSION
rm -f VERSION
# openssl.sh's prefix has to be here too, even though ffmpeg itself uses
# schannel: srt.pc carries "Requires.private: openssl libcrypto", and with
# --pkg-config-flags=--static pkg-config refuses srt outright when it cannot
# resolve those ("srt >= 1.3.0 not found using pkg-config").
# lib AND lib64: openssl defaults to lib64 on the mingw64 target, and
# openssl.sh only started pinning --libdir=lib after that bit us.
export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib64/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export CFLAGS="-isystem $INSTALL_PREFIX_CMAKE/sysroot/include $CFLAGS $ARCHFLAGS"
export LDFLAGS="-L$INSTALL_PREFIX_CMAKE/sysroot/lib $LDFLAGS"

# GPU filters (see Linux/ffmpeg.sh for the long version). The SPIR-V compiler
# is the glslang the media stage built; the CUDA compiler is our own clang:
# llvm-mingw is built with the NVPTX backend (mstorsjo/llvm-mingw build-llvm.sh
# lists "ARM;AArch64;X86;NVPTX"), so unlike Linux no second compiler is needed.
# x86_64 only: NVIDIA ships no Windows-on-ARM driver, so *_cuda filters there
# would be dead code in every binary.
declare -a FFMPEG_GPU_FLAGS=(
  --glslc="$INSTALL_PREFIX_CMAKE/sysroot/bin/glslang.exe"
)
if [[ "$SDK_ARCH" == "x86_64" ]]; then
  if "$CC" -print-targets 2>/dev/null | grep -q '^ *nvptx64'; then
    FFMPEG_GPU_FLAGS+=( --enable-cuda-llvm --nvcc="$CC" --nvccflags="--cuda-gpu-arch=sm_52 --cuda-feature=+ptx75 -O2" )
  else
    echo "ffmpeg.sh: $CC has no NVPTX target -- the *_cuda filters need one" >&2
    exit 1
  fi
fi

# Feature flags live in common/ffmpeg-features{,.mingw}; only what varies per
# build is here. Unquoted $(...) on purpose -- word-split, like $(cat qtfeatures).
./configure \
  $(ffmpeg_features mingw $SDK_ARCH) \
  --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" \
  --pkg-config="pkg-config" \
  --extra-cflags=" $CFLAGS " \
  --extra-ldflags=" $LDFLAGS " \
  --extra-libs=" $LDFLAGS " \
  --prefix="$INSTALL_PREFIX/ffmpeg" \
  "${FFMPEG_GPU_FLAGS[@]}" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

# configure drops a filter whose dependency is missing without a word; assert
# the GPU filter families we ship (common/ffmpeg-check.sh).
source "$SDK_COMMON_ROOT/common/ffmpeg-check.sh"
ffmpeg_require_config \
  CONFIG_GBLUR_VULKAN_FILTER CONFIG_SCALE_VULKAN_FILTER CONFIG_OVERLAY_VULKAN_FILTER \
  CONFIG_XFADE_VULKAN_FILTER CONFIG_NLMEANS_VULKAN_FILTER CONFIG_V360_VULKAN_FILTER \
  CONFIG_LIBPLACEBO_FILTER CONFIG_SCALE_D3D11_FILTER CONFIG_VPP_AMF_FILTER
if [[ "$SDK_ARCH" == "x86_64" ]]; then
  ffmpeg_require_config CONFIG_SCALE_CUDA_FILTER CONFIG_YADIF_CUDA_FILTER CONFIG_OVERLAY_CUDA_FILTER CONFIG_CHROMAKEY_CUDA_FILTER
fi
ffmpeg_report_gpu_filters

$MAKE V=1 -j1
$MAKE install
)
