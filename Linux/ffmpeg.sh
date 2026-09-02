#!/bin/bash -eu

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh clang
source ../common/clone-ffmpeg.sh
source ../common/ffmpeg-features.sh

if [[ -f $INSTALL_PREFIX/ffmpeg/bin/ffprobe ]]; then
  exit 0
fi

mkdir -p ffmpeg-build
cd ffmpeg-build

# media-deps.sh installs the codecs, the SRT protocol and the hwaccel headers
# into the sysroot; openssl comes from the core stage.
export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"

# Sanitised copy of the DISTRO's libdrm.pc, ahead of the real one.
#
# almalinux's libdrm.pc carries "Requires.private: valgrind" (libdrm is built
# with valgrind annotations), so with --pkg-config-flags=--static -- which our
# own static .pc files require -- pkg-config answers
#   -ldrm -L/usr/lib64/valgrind -lcoregrind-amd64-linux -lvex-amd64-linux -lgcc
# and the probe dies on "cannot find -lcoregrind-amd64-linux". ffmpeg's libdrm
# check is soft, so libdrm was silently disabled and the RPi patch then failed
# the build with "ERROR: v4l2-request requires --enable-libdrm" -- i.e. no
# hardware HEVC decoding on Raspberry Pi and friends. Reproduced in an
# almalinux:9 container.
#
# We link libdrm.so dynamically, so its static private deps are meaningless to
# us; dropping the line is exactly right and changes nothing else. This is a
# throwaway file in the build tree, NOT in the sysroot: nothing about it reaches
# the shipped SDK, and it does not touch the core dirs the media stage must
# leave alone (see .github/sysroot-guard.sh).
# Installing valgrind-devel instead would have "worked" and been much worse:
# --static would then bake -L/usr/lib64/valgrind -lcoregrind... into
# libavutil's EXTRALIBS, and every consumer would inherit it.
if drm_pcdir=$(pkg-config --variable=pcfiledir libdrm 2>/dev/null) \
   && [[ -f "$drm_pcdir/libdrm.pc" ]]; then
  mkdir -p pkgconfig-overrides
  sed -e 's/^Requires\.private:.*valgrind.*$/Requires.private:/' \
    "$drm_pcdir/libdrm.pc" > pkgconfig-overrides/libdrm.pc
  export PKG_CONFIG_PATH="$PWD/pkgconfig-overrides:$PKG_CONFIG_PATH"
  echo "ffmpeg.sh: shadowing $drm_pcdir/libdrm.pc without its valgrind Requires.private"
fi

# Only what genuinely varies per build lives here; the feature flags are in
# common/ffmpeg-features{,.linux}.
declare -a FFMPEG_LOCAL_FLAGS=(
  --extra-cflags="$CFLAGS -fPIC -I$INSTALL_PREFIX/sysroot/include"
  --extra-ldflags="-L$INSTALL_PREFIX/sysroot/lib -L$INSTALL_PREFIX/sysroot/lib64"
  --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC"
  --cxx="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CXX"
  --prefix=$INSTALL_PREFIX/ffmpeg
)

# FIXME apply librelec patches:
# https://github.com/LibreELEC/LibreELEC.tv/blob/master/packages/multimedia/ffmpeg/package.mk

declare -a FFMPEG_AARCH64_FLAGS=(
  --arch=aarch64
  --cpu=$GCC_CPU
  # libv4l2 needs libjpeg, and the SDK now builds one (see LIBJPEGTURBO_VERSION
  # in common/versions.sh). The shared flag file passes --pkg-config-flags
  # =--static -- our own static .pc files require it, srt.pc alone has
  # "Requires.private: openssl libcrypto" -- and static resolution expands
  # libv4l2.pc to "-lv4l2 -lpthread -lv4lconvert -lrt -lm -ljpeg". The build
  # image has libv4l-devel but no jpeg devel, so configure used to die here with
  # "ERROR: libv4l2 not found using pkg-config" behind "cannot find -ljpeg".
  # -L$INSTALL_PREFIX/sysroot/lib comes first in --extra-ldflags, so -ljpeg now
  # resolves to OUR libjpeg.a rather than to whatever the distro happens to ship.
  --enable-libv4l2
  --enable-v4l2-m2m
  --enable-sand
  --enable-v4l2-request
  --enable-libdrm
  --enable-libudev
)
declare -a FFMPEG_X86_64_FLAGS=(
  # --arch is the ISA family and --cpu the tuning target; they are not
  # interchangeable. Passing --arch=x86-64-v3 (as this script did until now)
  # matches no entry in configure's arch case, leaves arch=unknown, and silently
  # turns off ARCH_X86 and HAVE_X86ASM -- i.e. every x86 assembly kernel in
  # libavcodec/libswscale. The check after configure guards this.
  --arch=x86_64
  --cpu=$GCC_CPU
  --disable-libv4l2
  --enable-indev=v4l2
)
declare -n FFMPEG_ARCH_FLAGS=FFMPEG_${ARCH_VARNAME}_FLAGS

# GPU filters. Both compilers below only run at build time; nothing new is
# linked or dlopen'd in the result.
#
#  --glslc: ffmpeg 9 precompiles its Vulkan filter shaders with a glslang
#    binary. Passed explicitly (the one the media stage just built) rather than
#    left to configure's PATH probe: the probe is silent when it fails, and that
#    silence is how earlier SDKs shipped --enable-vulkan with zero *_vulkan
#    filters.
#  --nvcc: --enable-cuda-llvm compiles the *_cuda filters' .cu sources to PTX
#    text with clang (no CUDA SDK; compat/cuda/cuda_runtime.h is in-tree). The
#    SDK's own clang is built for $LLVM_ARCH only (Linux/llvm.sh), so it cannot
#    target NVPTX; the build image's distro clang (llvm-toolset) is built with
#    every backend and is used for this one job. sm_52 rather than configure's
#    sm_30 default: recent clangs refuse Kepler, and PTX is forward-compatible,
#    so sm_52 covers every GPU from Maxwell (2014) on -- ffmpeg embeds ONE
#    PTX per kernel and the driver JITs it for the GPU at hand, so there is no
#    multi-generation build to do. What limits compatibility is the PTX ISA
#    version the compiler writes (clang 19 defaults to 8.5, i.e. driver >= 555,
#    mid-2024); --cuda-feature=+ptx75 pins it to 7.5 (CUDA 11.5, driver >= 495,
#    2021) which these kernels do not need more than.
declare -a FFMPEG_GPU_FLAGS=(
  --glslc="$INSTALL_PREFIX/sysroot/bin/glslang"
)
NVPTX_CLANG=
for candidate in /usr/bin/clang /usr/lib64/llvm*/bin/clang; do
  if [[ -x "$candidate" ]] && "$candidate" -print-targets 2>/dev/null | grep -q '^ *nvptx64'; then
    NVPTX_CLANG="$candidate"; break
  fi
done
if [[ -n "$NVPTX_CLANG" ]]; then
  FFMPEG_GPU_FLAGS+=( --enable-cuda-llvm --nvcc="$NVPTX_CLANG" --nvccflags="--cuda-gpu-arch=sm_52 --cuda-feature=+ptx75 -O2" )
else
  echo "ffmpeg.sh: no clang with an NVPTX target found -- the *_cuda filters need one (llvm-toolset in Dockerfile.centos)" >&2
  exit 1
fi

# Unquoted on purpose: ffmpeg_features output is word-split, like $(cat qtfeatures).
../ffmpeg-$FFMPEG_VERSION/configure \
  $(ffmpeg_features linux $CPU_ARCH) "${FFMPEG_LOCAL_FLAGS[@]}" "${FFMPEG_ARCH_FLAGS[@]}" "${FFMPEG_GPU_FLAGS[@]}" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

# The asm above is the whole point of getting --arch right, so fail loudly
# rather than shipping a silently scalar build.
if [[ "$ARCH_VARNAME" == "X86_64" ]] && ! grep -qx 'HAVE_X86ASM=yes' ffbuild/config.mak; then
  echo "ffmpeg.sh: x86 assembly is disabled -- check --arch/--cpu" >&2
  exit 1
fi

# Same treatment for the GPU filter families: configure drops a filter whose
# dependency is missing without a word, so assert them (common/ffmpeg-check.sh).
source "$SDK_COMMON_ROOT/common/ffmpeg-check.sh"
ffmpeg_require_config \
  CONFIG_GBLUR_VULKAN_FILTER CONFIG_SCALE_VULKAN_FILTER CONFIG_OVERLAY_VULKAN_FILTER \
  CONFIG_XFADE_VULKAN_FILTER CONFIG_NLMEANS_VULKAN_FILTER CONFIG_V360_VULKAN_FILTER \
  CONFIG_LIBPLACEBO_FILTER \
  CONFIG_SCALE_CUDA_FILTER CONFIG_YADIF_CUDA_FILTER CONFIG_OVERLAY_CUDA_FILTER CONFIG_CHROMAKEY_CUDA_FILTER
ffmpeg_report_gpu_filters

make -j$NPROC
make install
