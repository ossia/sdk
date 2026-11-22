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

if openssl_is_current "$INSTALL_PREFIX/openssl/lib/libssl.a"; then
  exit 0
fi

# The Windows ARM SDK builds SRT without encryption (see media-deps.sh).
if [[ "$TARGET_ARCH" != "x86_64" ]]; then
  echo "openssl.sh: OpenSSL is not packaged for $TARGET_ARCH -- skipping." >&2
  echo "            libsrt is built without encryption there (see media-deps.sh);" >&2
  echo "            SRT still works, but passphrase-protected streams do not." >&2
  exit 0
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
