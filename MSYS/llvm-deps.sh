#!/bin/bash

source ./common.sh
# Install the prebuilt llvm-mingw cross toolchain into $INSTALL_PREFIX/llvm
# (provides x86_64-w64-mingw32 clang + runtime used by the rest of the build).
source ../common/clone-llvm-mingw.sh

# Qt's cpp-winrt and vulkan feature compile-tests use the llvm-mingw toolchain,
# which does not search $MSYSTEM_PREFIX/include. Copy the headers Qt needs from
# the MSYS2 cppwinrt + vulkan-headers packages into the toolchain (these were
# manual steps / a separately-installed Vulkan SDK before).
if [[ -d "$MSYSTEM_PREFIX/include/winrt" ]]; then
  cp -rf "$MSYSTEM_PREFIX/include/winrt" "$INSTALL_PREFIX/llvm/include/"
fi
if [[ -f "$MSYSTEM_PREFIX/lib/libruntimeobject.a" ]]; then
  cp -f "$MSYSTEM_PREFIX/lib/libruntimeobject.a" "$INSTALL_PREFIX/llvm/$MINGW_TRIPLE/lib/"
fi
for d in vulkan vk_video; do
  if [[ -d "$MSYSTEM_PREFIX/include/$d" ]]; then
    cp -rf "$MSYSTEM_PREFIX/include/$d" "$INSTALL_PREFIX/llvm/include/"
  fi
done

# Qt 6.12's windows platform plugin needs windows.graphics.display.interop.h
# (IDisplayInformationStaticsInterop, for per-monitor HDR). That interop header
# is Windows-SDK-only -- mingw-w64 has no IDL for it, so neither this toolchain
# nor MSYS2 ships it. Generate it from a minimal IDL with the toolchain's widl
# (modelled on mingw-w64's windows.graphics.capture.interop.idl; IID + signatures
# match the Windows SDK). Methods return opaque void**, so no Display import is
# needed. Write into the REAL generic-w64-mingw32/include (where the sibling
# windows.*.interop.h live); <triple>/include is a symlink to it and is not
# writable on the Windows runner.
_wgdi_h="$INSTALL_PREFIX/llvm/generic-w64-mingw32/include/windows.graphics.display.interop.h"
if [[ ! -f "$_wgdi_h" ]]; then
  _wgdi_idl="$(mktemp -d)/windows.graphics.display.interop.idl"
  cat > "$_wgdi_idl" <<'IDL'
#ifdef __WIDL__
#pragma winrt ns_prefix
#endif
import "inspectable.idl";
[
    uuid(7449121c-382b-4705-8da7-a795ba482013)
]
interface IDisplayInformationStaticsInterop : IInspectable
{
    HRESULT GetForWindow([in] HWND window, [in] REFIID riid, [out, iid_is(riid)] void **displayInformation);
    HRESULT GetForMonitor([in] HMONITOR monitor, [in] REFIID riid, [out, iid_is(riid)] void **displayInformation);
}
IDL
  "$INSTALL_PREFIX/llvm/bin/$MINGW_TRIPLE-widl" -h \
    -I"$INSTALL_PREFIX/llvm/generic-w64-mingw32/include" \
    -I"$INSTALL_PREFIX/llvm/$MINGW_TRIPLE/include" \
    -o "$_wgdi_h" "$_wgdi_idl"
fi
