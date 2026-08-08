#!/bin/bash -eu

# macOS openssl. Used by ffmpeg (tls + dtls, so https/rtmps/srtp/whip) and by
# libsrt for its encryption.
#
# SecureTransport is not an option for this: Apple deprecated it, and ffmpeg's
# dtls_protocol_deps_any is "openssl schannel gnutls mbedtls" -- securetransport
# is not in that list, so the whip muxer and srtp are simply unavailable without
# a real openssl. Linux gets its openssl from the core stage; on macOS nothing
# else needs it, so it is built here in the media stage and does not rotate the
# (expensive) macOS core hash.

source ./common.sh
source ../common/clone-openssl.sh

if [[ -f "$INSTALL_PREFIX/openssl/lib/libssl.a" ]]; then
  exit 0
fi

# One slice only, even on the x86_64 leg which ships fat x86_64+x86_64h ffmpeg
# libraries: ld64 links an x86_64h binary against plain x86_64 archives happily
# (verified), and openssl's perlasm emits per-arch .s files, so a two-slice
# build here would mean configuring and lipo-ing twice for no benefit.
if [[ "$TARGET_ARCH" == "arm64" ]]; then
  OPENSSL_TARGET=darwin64-arm64-cc
  OPENSSL_ARCH=arm64
else
  OPENSSL_TARGET=darwin64-x86_64-cc
  OPENSSL_ARCH=x86_64
fi

(
cd "openssl-$OPENSSL_VERSION"
make distclean >/dev/null 2>&1 || true
# -arch has to be baked into $CC, not passed to Configure: Configure treats any
# bare word as a target name, so "-arch arm64" makes it read "arm64" as a second
# target and die with "target already defined". The single-token flags in
# $CFLAGS_NOARCH are fine as Configure arguments -- it collects unrecognised
# -options as cflags.
CC="${CCACHE_LAUNCHER:+$CCACHE_LAUNCHER }$CC -arch $OPENSSL_ARCH" \
  ./Configure "$OPENSSL_TARGET" -no-shared -no-tests \
    --prefix="$INSTALL_PREFIX/openssl" \
    $CFLAGS_NOARCH
make -j"$NPROC"
# install_sw only: no docs, and no man pages to clean up afterwards.
make install_sw install_ssldirs
)
