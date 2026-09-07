#!/bin/bash -eux
export SDK_COMMON_ROOT=$PWD
source ./common.sh clang

source "$SDK_COMMON_ROOT/common/clone-qt.sh"

declare -a QT_AARCH64_FLAGS=(
  -opengl es2
  -feature-opengles3
  -feature-opengles31
  -feature-opengles32
)

declare -a QT_X86_64_FLAGS=(
  -opengl desktop
)

declare -n QT_ARCH_FLAGS=QT_${ARCH_VARNAME}_FLAGS

# QtDBus dlopens libdbus-1 (QLibrary, tries .so.3 then .so.2) instead of taking a
# DT_NEEDED on it, so the AppImage runs on hosts whose libdbus differs or is
# absent -- QtDBus then just fails its calls and QDesktopServices::openUrl()
# falls through to xdg-open. Set as a feature variable on purpose: configure's
# documented -dbus-runtime is accepted but never reaches INPUT_dbus in 6.12, so
# it silently leaves dbus-linked auto-detected ON.
mkdir -p qt6-build-static
(
  cd qt6-build-static

  export OPENSSL_LIBS="$INSTALL_PREFIX/openssl/lib/libssl.a $INSTALL_PREFIX/openssl/lib/libcrypto.a -ldl -pthread"
  ../qt/configure \
  $(cat "$SDK_COMMON_ROOT/common/qtfeatures") \
  $(cat "$SDK_ROOT/common/qtfeatures.$QT_MODE") \
  -feature-vnc \
  -feature-library \
  -feature-wayland-client \
  -feature-eglfs_gbm \
  -feature-eglfs_x11 \
  -feature-eglfs_egldevice \
  -no-feature-wayland-server \
  -no-feature-libudev \
  -no-feature-glib \
  -no-feature-gtk3 \
  -system-zlib \
  -eglfs \
  -kms \
  -xcb \
  -vulkan \
  -linker lld \
  -platform linux-clang-libc++ \
  -unity-build \
  -prefix $INSTALL_PREFIX/qt6-static \
  -openssl-linked \
  "${QT_ARCH_FLAGS[@]}" \
  -- \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DCMAKE_CXX_STANDARD=23 \
  -DFEATURE_dbus_linked=OFF \
  -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX;$INSTALL_PREFIX/sysroot" \
  -DFREETYPE_DIR="$INSTALL_PREFIX/sysroot" \
  -Dharfbuzz_DIR="$INSTALL_PREFIX/sysroot" \
  -DHARFBUZZ_INCLUDE_DIRS="$INSTALL_PREFIX/sysroot/include" \
  -DHARFBUZZ_LIBRARIES="$INSTALL_PREFIX/sysroot/lib/libharfbuzz.a" \
  -DOPENSSL_ROOT_DIR="$INSTALL_PREFIX/openssl" \
  -DQT_DISABLE_DEPRECATED_UP_TO=0x060900

  cmake --build .
  cmake --build . --target install
)
