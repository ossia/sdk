#!/bin/bash -eux

source ./common.sh clang
source ../common/clone-pipewire.sh

if [[ -f $INSTALL_PREFIX/pipewire/bin/pipewire ]]; then
  exit 0
fi
(
  cd pipewire-$PIPEWIRE_VERSION
  rm -rf build
  
  # -Dopus=disabled: pipewire's opus option defaults to 'auto', and
  # CentOS/common.release.sh puts $INSTALL_PREFIX/sysroot/lib/pkgconfig on
  # PKG_CONFIG_PATH for every Linux build -- so the moment media-deps.sh started
  # installing opus.pc there, pipewire silently enabled its RTP-Opus module and
  # then failed to compile it: opus.pc says "Cflags: -I${includedir}/opus" while
  # module-rtp/opus.c does #include <opus/opus.h>, which needs the PARENT
  # directory. Distros get away with it because their opus headers sit under
  # /usr/include, which is implicit.
  #
  # Disabled rather than fixed with an extra -I: these are pipewire *server*
  # modules, and the SDK ships pipewire only so score can link the client
  # library -- RTP modules come from the user's own pipewire daemon. Nothing is
  # lost; before this the module was simply never built.
  PW_OPTS=(--prefix=$INSTALL_PREFIX/pipewire "-Dsession-managers=[]"
           -Dexamples=disabled -Dtests=disabled -Dsystemd=disabled
           -Ddbus=disabled -Dflatpak=disabled -Dopus=disabled)
  meson setup build "${PW_OPTS[@]}"
  meson configure build "${PW_OPTS[@]}"
  meson compile -C build
  meson install -C build
)
