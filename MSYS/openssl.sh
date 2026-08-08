#!/bin/bash -eu

# Windows openssl. NOT used by ffmpeg -- that takes its TLS from schannel, which
# is a system SSP, needs nothing shipped and validates against the Windows
# certificate store (see common/ffmpeg-features.mingw). This exists for libsrt,
# whose CMakeLists does an unconditional find_package(OpenSSL) unless encryption
# is switched off, and SRT without encryption cannot do passphrase-protected
# streams -- which is how SRT is normally deployed.
#
# Media stage, so it does not rotate the Windows core hash.

source ./common.sh
source ../common/clone-openssl.sh

if [[ -f "$INSTALL_PREFIX/openssl/lib/libssl.a" ]]; then
  exit 0
fi

# OpenSSL 3.5 ships no mingw target for Windows-on-ARM (Configurations/10-main.conf
# has mingw and mingw64 only, both x86). CI builds the x86_64 leg only; fail
# loudly rather than silently configuring an x86 target for an ARM build.
if [[ "$TARGET_ARCH" != "x86_64" ]]; then
  echo "openssl.sh: no OpenSSL mingw target for $TARGET_ARCH; libsrt must be" >&2
  echo "            built with -DENABLE_ENCRYPTION=OFF on this arch." >&2
  exit 1
fi

(
cd "openssl-$OPENSSL_VERSION"
CC="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC" \
  ./Configure mingw64 -no-shared -no-tests \
    --prefix="$INSTALL_PREFIX_CMAKE/openssl" \
    --libdir=lib
$MAKE -j"$NPROC"
# install_sw only: no docs, nothing to clean up afterwards.
$MAKE install_sw install_ssldirs
)
