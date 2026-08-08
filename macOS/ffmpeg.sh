#!/bin/bash -eu

export SDK_COMMON_ROOT=$(cd "$PWD/.." ; pwd -P)
source ./common.sh
source ../common/clone-ffmpeg.sh
source ../common/ffmpeg-features.sh

# media-deps.sh installs the codecs and libsrt into $INSTALL_PREFIX, openssl.sh
# into $INSTALL_PREFIX/openssl. common.sh pins PKG_CONFIG_LIBDIR at the former
# to keep Homebrew out, so extend it rather than replacing it.
# freetype and harfbuzz (--enable-libfreetype/--enable-libharfbuzz, i.e.
# drawtext) each get their OWN prefix on macOS -- unlike Linux and MSYS, where
# freetype.sh installs into the shared sysroot -- so both have to be named here
# or the probe falls back to whatever Homebrew has, which is exactly what
# PKG_CONFIG_LIBDIR exists to prevent. freetype2.pc also Requires harfbuzz, so
# neither one alone is enough.
export PKG_CONFIG_LIBDIR="$INSTALL_PREFIX/lib/pkgconfig:$INSTALL_PREFIX/openssl/lib/pkgconfig:$INSTALL_PREFIX/freetype/lib/pkgconfig:$INSTALL_PREFIX/harfbuzz/lib/pkgconfig"

# Feature flags live in common/ffmpeg-features{,.macos}. Unquoted on purpose:
# the output is word-split, exactly like $(cat qtfeatures) in qt.sh.
# TARGET_ARCH is arm64/x86_64; the feature-file arch layer is named aarch64.
if [[ "$TARGET_ARCH" == "arm64" ]]; then FEATURES_ARCH=aarch64; else FEATURES_ARCH=x86_64; fi
declare -a FFMPEG_COMMON_FLAGS=( $(ffmpeg_features macos $FEATURES_ARCH) )

export FFMPEG_ARM64_FLAGS=(
 --arch=aarch64
 --cpu=$CPU_TARGET
 --prefix=$INSTALL_PREFIX/ffmpeg
 --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC  -arch arm64 "
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -I$INSTALL_PREFIX/include"
 --extra-ldflags="$CFLAGS_NOARCH -L$INSTALL_PREFIX/lib"
)

# ONE x86_64 pass, not the old x86_64 + x86_64h pair.
#
# --arch=x86_64h is not a value ffmpeg's configure knows: it falls through to
# arch=unknown and silently turns off ARCH_X86 and HAVE_X86ASM. The shipped
# x86_64h slice therefore has NO x86 assembly at all -- 2514 asm symbols in the
# x86_64 slice of libavcodec.a versus 0 in the x86_64h one -- and macOS prefers
# that slice on every Haswell-or-newer Mac. So the second pass was not a
# tuning win, it was a large loss.
#
# Passing --arch=x86_64 for an x86_64h build instead would restore the assembly
# but make the archives mixed (nasm cannot emit the x86_64h subtype), and lipo
# refuses to merge a mixed archive with the x86_64 one.
#
# A single native x86_64 build links into both slices of a fat consumer: ld
# accepts a native Mach-O x86_64 object into an x86_64h link (cpusubtype
# CPU_SUBTYPE_X86_64_ALL, and x86_64 code runs on x86_64h hardware). Qt,
# llvm-libs and score keep their x86_64h slices; only ffmpeg and its codecs are
# thin, and they gain the assembly back. See macOS/media-deps.sh for the one
# caveat -- LLVM bitcode members are the exception ld cannot bridge.
export FFMPEG_X86_64_FLAGS=(
 --arch=x86_64
 --cpu=$CPU_TARGET
 --prefix=$INSTALL_PREFIX/ffmpeg
 --cc="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC  -arch x86_64 "
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -I$INSTALL_PREFIX/include"
 --extra-ldflags="$CFLAGS_NOARCH -L$INSTALL_PREFIX/lib"
)

# Plain array copy, not `declare -n`: macOS ships bash 3.2, which has no
# namerefs (Linux/ffmpeg.sh can use them, its container has bash 5).
if [[ "$TARGET_ARCH" == "arm64" ]]; then
  FFMPEG_ARCH_FLAGS=("${FFMPEG_ARM64_FLAGS[@]}")
else
  FFMPEG_ARCH_FLAGS=("${FFMPEG_X86_64_FLAGS[@]}")
fi

(
rm -rf ffmpeg-build
mkdir -p ffmpeg-build
cd ffmpeg-build

# ffmpeg's configure appends the environment's $CFLAGS to every probe, and
# common.sh sets it to the FAT flags ("-arch x86_64 -arch x86_64h"). Combined
# with the single -arch in --cc that gives three -arch options and clang dies
# with "cannot use 'cpp-output' output with multiple -arch options". The arch
# belongs to --cc and --extra-cflags here, so drop it from the environment.
export CFLAGS="$CFLAGS_NOARCH"
export CXXFLAGS="$CFLAGS_NOARCH"
export LDFLAGS="$CFLAGS_NOARCH"

xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_ARCH_FLAGS[@]}" \
  || { echo "::group::ffmpeg config.log (tail)"; tail -n 150 ffbuild/config.log; echo "::endgroup::"; exit 1; }

# The assembly is the whole reason --arch is spelled out above; fail loudly
# rather than shipping a silently scalar build (this is exactly how the old
# x86_64h slice regressed unnoticed).
if [[ "$TARGET_ARCH" != "arm64" ]] && ! grep -qx 'HAVE_X86ASM=yes' ffbuild/config.mak; then
  echo "ffmpeg.sh: x86 assembly is disabled -- check --arch/--cpu" >&2
  exit 1
fi

xcrun make -j$NPROC
xcrun make install
)
