#!/bin/bash -eux

# DirectX Shader Compiler runtime.
#
# Qt's D3D12 backend runtime-compiles HLSL, and for shader model 6.0 and above
# it does so through DXC:
#
#   qrhid3d12.cpp, compileHlslShaderSource()
#     if (key.sourceVersion().version() >= 60) {
#   #ifdef QRHI_D3D12_HAS_DXC
#         return dxcCompile(hlslSource, target, flags, error);
#   #else
#         qWarning("...the Qt build has no support for DXC...");
#
# The SDK's Qt is built WITH that support -- the dxcompiler symbol is present in
# libQt6Gui.a -- but Qt loads dxcompiler.dll dynamically at runtime, and nothing
# was shipping it. So anything asking for SM 6.x got the warning and a failed
# pipeline instead of a compiled shader.
#
# That matters beyond a missing feature. Qt's search is
#
#   for (int sm = 67; sm >= 50; --sm)  { ... if (found) break; }
#
# so it stops at the FIRST shader model it finds. A build that bakes SM 6.x
# without these DLLs present does not quietly fall back to 5.0 -- it finds the
# 6.x source, breaks out of the loop, and fails. Shipping the runtime is
# therefore a prerequisite for score requesting anything above 5.0 on D3D12,
# not an optional extra.
#
# TWO libraries are required, not one:
#   dxcompiler.dll  the compiler itself
#   dxil.dll        the signing library. Without it DXC emits unsigned DXIL and
#                   D3D12 refuses to load it outside Developer Mode -- which is
#                   a worse failure than not having DXC at all, because it only
#                   appears on the customer's machine.
#
# dxil.dll is Microsoft-signed and is not redistributable through msys2: there
# is no mingw package that carries it. The official release archive is the only
# source, which is why this is a curl of a pinned release rather than a pacman
# package like most of deps.sh.

source ./common.sh

# Pinned deliberately: DXC releases change the DXIL validator version, and a
# validator newer than the user's runtime is rejected. Bump consciously.
DXC_RELEASE="v1.8.2407"
DXC_ZIP="dxc_2024_07_31.zip"

if [[ ! -f "$INSTALL_PREFIX/bin/dxcompiler.dll" ]]; then
(
  rm -rf dxc-tmp
  mkdir -p dxc-tmp
  cd dxc-tmp

  curl -ksSL \
    "https://github.com/microsoft/DirectXShaderCompiler/releases/download/$DXC_RELEASE/$DXC_ZIP" \
    -o dxc.zip
  unzip -q dxc.zip

  # The archive lays the runtime out per-architecture: bin/x64, bin/arm64.
  case "$TARGET_ARCH" in
    arm64)  DXC_BIN_DIR=bin/arm64 ;;
    *)      DXC_BIN_DIR=bin/x64 ;;
  esac

  if [[ ! -f "$DXC_BIN_DIR/dxcompiler.dll" ]]; then
    echo "dxc.sh: $DXC_BIN_DIR/dxcompiler.dll not in $DXC_ZIP."
    echo "The release layout changed; check the archive before bumping DXC_RELEASE."
    exit 1
  fi

  mkdir -p "$INSTALL_PREFIX/bin"
  cp "$DXC_BIN_DIR/dxcompiler.dll" "$INSTALL_PREFIX/bin/"

  # dxil.dll is absent from the arm64 tree in some releases. Not fatal on its
  # own -- but say so loudly, because the resulting unsigned DXIL fails only on
  # machines without Developer Mode, i.e. every customer machine.
  if [[ -f "$DXC_BIN_DIR/dxil.dll" ]]; then
    cp "$DXC_BIN_DIR/dxil.dll" "$INSTALL_PREFIX/bin/"
  else
    echo "dxc.sh: WARNING: no dxil.dll for $TARGET_ARCH in $DXC_ZIP."
    echo "SM 6.x shaders will compile but produce UNSIGNED DXIL, which D3D12"
    echo "refuses to load unless Developer Mode is on. Do not ship this."
  fi
)
fi

ls -la "$INSTALL_PREFIX/bin/dxcompiler.dll" "$INSTALL_PREFIX/bin/dxil.dll" 2>&1 || true
