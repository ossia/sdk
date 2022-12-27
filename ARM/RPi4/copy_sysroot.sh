#!/bin/bash -eux

SYSROOT="$1"
SDK_INSTALL_ROOT="$2"
DEBIAN_MULTIARCH="$3"

echo "Running on : '$1'  =>  '$2'"
cd "$SDK_INSTALL_ROOT/pi"

sudo cp "$SYSROOT/usr/lib/$DEBIAN_MULTIARCH"/*.o "$SYSROOT"/usr/lib/
sudo rsync -az "$SYSROOT"/lib sysroot
sudo rsync -az "$SYSROOT"/usr/include sysroot/usr
sudo rsync -az "$SYSROOT"/usr/lib sysroot/usr

# AArch64 does not have /opt/vc as the drivers don't exist...
if [[ -d "$SYSROOT"/opt/vc ]]; then
  sudo rsync -az "$SYSROOT"/opt/vc sysroot/opt
fi