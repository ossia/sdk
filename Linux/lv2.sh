#!/bin/bash -eu

source ./common.sh clang
source ../common/clone-lv2.sh

(

cd lv2kit

rm -rf build
LV2_OPTS=(
  --prefix="$INSTALL_PREFIX/lv2"
  -Ddocs=disabled
  -Dtests=disabled
  -Dtools=disabled
  -Ddefault_library=static
  --wrap-mode=forcefallback
)
if [[ "${SDK_DEBUG:-0}" == 1 ]]; then
  LV2_OPTS+=(
    --buildtype=debug
    -Db_ndebug=false
    -Db_lundef=false
    # zix deliberately erases typed hash/equality callbacks behind const void*
    # function pointers. FunctionSanitizer treats that C callback ABI as a bad
    # indirect call, so suppress only that UBSan check for the LV2 stack.
    "-Dc_args=-fno-sanitize=function"
    "-Dcpp_args=-fno-sanitize=function"
    "-Dc_link_args=$SANITIZER_FLAGS"
    "-Dcpp_link_args=$SANITIZER_FLAGS"
  )
fi
meson setup build "${LV2_OPTS[@]}"
meson configure build "${LV2_OPTS[@]}"
meson compile -C build
meson install -C build
)