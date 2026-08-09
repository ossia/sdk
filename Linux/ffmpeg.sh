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

# Unquoted on purpose: ffmpeg_features output is word-split, like $(cat qtfeatures).
../ffmpeg-$FFMPEG_VERSION/configure \
  $(ffmpeg_features linux $CPU_ARCH) "${FFMPEG_LOCAL_FLAGS[@]}" "${FFMPEG_ARCH_FLAGS[@]}" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

# The asm above is the whole point of getting --arch right, so fail loudly
# rather than shipping a silently scalar build.
if [[ "$ARCH_VARNAME" == "X86_64" ]] && ! grep -qx 'HAVE_X86ASM=yes' ffbuild/config.mak; then
  echo "ffmpeg.sh: x86 assembly is disabled -- check --arch/--cpu" >&2
  exit 1
fi

make -j$NPROC
make install
