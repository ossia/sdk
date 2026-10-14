# Local Qt patches

Patches applied to a Qt module after `qt_pick` runs, from
`common/qt-patches/<module>/*.patch`, in filename order. See `qt_apply_local`
in `common/clone-qt.sh`.

Use this for fixes that have no applicable Gerrit change to cherry-pick: not yet
submitted upstream, not yet merged, or a dev change whose ref conflicts with
the 6.12 branch and has no backport. Cleanly applicable changes belong in
`qt_pick`, which tracks the upstream review instead of a snapshot.

A patch that is already present in the tree is skipped, not an error, so a Qt
bump that picks up the fix upstream does not break the build. Delete the file
when that happens.

## Current patches

### qtbase/0001-build-preserve-shared-symbol-exports.patch

The static-export Gerrit pick replaces Qt's normal shared-library export
condition with its static-build switch. That is correct for the SDK's static
targets but strips every module export while building WASM's native shared host
tools. Preserve the standard shared-library branch, then enable the extra
exports only for static library builds.

### qtbase/0001-corelib-include-exception-for-terminate.patch

Clang 23's libc++ no longer exposes `std::terminate` through Qt's transitive
includes. The removed `qTerminate()` compatibility API needs `<exception>`
directly. Remove this patch once the include lands upstream.

### qtbase/0001-rhi-gl-support-unsigned-uniform-arrays.patch

The dev change fixes std140 unpacking and uploads for arrays of unsigned
uniforms. Its Gerrit ref conflicts with the `mat2` fix already backported to
6.12, so this is the resolved 6.12 form. Replace it with a 6.12 Gerrit pick if
Qt creates one; otherwise remove it when the branch absorbs the fix.

### qtquick3d/0001-xatlas-include-stdlib.patch

Clang 23's libc++ no longer provides C allocation and sorting declarations
transitively. xatlas calls `realloc`, `free`, and `qsort`, so include their
defining C standard library header directly.

### qtquick3d/0002-directional-pcf-shadows-clamp-split-index.patch

`findSplitIndex()` returns -1 for a fragment past the last cascade split. The
directional PCF shadow path (the default `softShadowQuality`) indexed
`matrices[]`, `dimensionsInverted[]` and `atlasLocations[]` with it and only
masked the result afterwards; the hard path clamps first. On D3D12 the
out-of-bounds root-CBV read in DXIL hangs the GPU: DRED shows the first opaque
draw of the main pass never completing, then `DXGI_ERROR_DEVICE_HUNG`. Any
DirectionalLight with `castsShadow: true` whose camera sees past the last split
removes the device (score's docs `3d/gltf-checkers`). Clamp as the hard path
does; the masked output is unchanged. Not yet submitted upstream.

### qtbase/0001-darwin-futex-runtime-availability-check.patch

Qt 6.12 switched the Darwin futex backend from the private, weak-linked
`__ulock_*` to the public `os_sync_wait_on_address()` family, and dropped the
runtime availability check in the same move: `futexAvailable()` became
`constexpr true` and `QT_ALWAYS_USE_FUTEX` was defined unconditionally.

`os_sync_wait_on_address()` is macOS 14.4+. The SDK builds Qt with a 12.0
deployment target, so the symbol is weak-imported, resolves to NULL on anything
older, and the call branches to address 0 -- a SIGSEGV at 0x0 on the first
contended QMutex. Observed as a crash on startup on macOS 13.2.1, in
`QBasicMutex::lockInternal()` under `QQmlTypeLoader`.

The patch restores the runtime check (as 6.10 had for `__ulock_*`) and defines
`QT_ALWAYS_USE_FUTEX` only when the deployment target reaches 14.4. Qt 6.12
also removed its Mach-semaphore QMutex fallback; merely re-enabling the generic
path is invalid because Darwin has neither usable unnamed POSIX semaphores nor
`sem_timedwait`. The patch therefore restores `qmutex_mac.cpp` and its
platform-specific storage/selection from Qt 6.10. Machines with the address-wait
API still take the futex path; older systems use Mach semaphores.

Not yet submitted to Gerrit. Remove this file once it lands upstream.

### qtbase/0003-rhi-vk-keep-swapchain-pixelsize-in-sync.patch

Gerrit 726771 (`QRhiVulkan: keep pixelSize in sync`) is still open on dev and
stopped cherry-picking onto the 6.12 head: upstream's *rhi: vulkan: Wait on the
queue, not the device* turned the `df->vkDeviceWaitIdle(dev)` that 726771 moves
into a `deviceLost`-guarded `df->vkQueueWaitIdle(gfxQueue)`, so the deletion
half of the pick no longer matches. This is 726771 rebased: the wait still moves
above the `surfacePixelSize()` read, but it is upstream's queue wait that moves,
not the old device wait. Drop this and go back to `qt_pick` once 726771 lands
and is picked to 6.12.

### qtbase/0006-rhi-d3d12-stage-static-buffer-uploads-by-their-size.patch

`QRhiD3D12` sized the staging area of every static buffer upload by the whole
destination buffer, not by the uploaded range. score's Scene Preprocessor
queues hundreds of small uploads into 128 MB mesh buffers in one batch, which
asked for about 96 GB of upload heap and failed with `E_OUTOFMEMORY`. The patch
stages only the uploaded bytes. Not submitted upstream yet; remove it when an
equivalent fix lands.

### qtbase/0007-rhi-d3d12-generate-mipmaps-for-srgb-textures.patch

`QRhiD3D12`'s mipmap generators create typed UAVs in the texture's own format,
which is invalid for sRGB formats: the dispatch runs with null UAVs and the
device is removed. sRGB textures created with `UsedWithGenerateMips` are now
backed by the typeless format of their family, and the generators read and
write through its UNORM member, so the chain is filtered on encoded values
(within a fraction of a percent of the Vulkan blit on glTF textures). Not
submitted upstream yet.

### qtbase/0008-rhi-metal-buffer-size-buffer-srb-key.patch

SPIRV-Cross implements `length()` on a runtime array through a "buffer size
buffer", which qtshadertools places at native buffer index 25. `QRhiMetal`
adds it to the SRB and keyed its entry in the shader's native resource binding
map by that native index, while the map is keyed by QRhi (SPIR-V) binding. An
SRB with its own binding 25 lost its map entry: the size buffer was either
never bound (binding 25 a storage buffer) or bound on top of a uniform buffer,
and every `length()` read another resource's contents, typically 0. The entry
is now keyed by a binding no application uses. Composes with
`0001-rhi-metal-vertex-buffer-origin-from-native-buffers.patch`, which reads
native indices only. Not submitted upstream yet.

### qtbase/0009-rhi-d3d11-readonly-storage-buffers-as-srv.patch and qtshadertools/0001-hlsl-readonly-storage-buffers-as-srv.patch

Qt bakes every storage block as an `RWByteAddressBuffer` UAV for HLSL. On
Direct3D 11 that means storage buffers cannot be read in vertex shaders (UAVs
exist only at the pixel and compute stages, so they read zero), and fxc rejects
UAV loads that feed gradient operations (X3662) or barrier-controlling flow
(X3663).

The qtshadertools patch adds an opt-in
`QShaderBaker::setHlslReadOnlyStorageBuffersAsSrv(bool)` (feature macro
`QT_SHADERTOOLS_HAS_HLSL_READONLY_SSBO_SRV`): readonly blocks become
`ByteAddressBuffer` SRVs in t registers after the images, recorded as
`{tN, -2}` in the native binding map. The qtbase patch makes `QRhiD3D11` bind
those through a cached raw buffer SRV at every stage; storage buffers are
created with `D3D11_BIND_SHADER_RESOURCE` too. Only D3D11 understands the
marker, so score enables the option for `QRhi::D3D11` only. The two patches
go together. Not submitted upstream yet.

### qtbase/0010-rhi-vk-depth-resolve-is-a-depth-attachment-write.patch

`toVkLayout()` maps `TexDepthResolveOutput` to
`VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL`, while `toVkAccess()` mapped
it to `VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT` and the resolve target was
registered with `TexColorOutputStage`. Layout and access disagreed, so the
validation layer rejected every barrier on a depth resolve target
(UNASSIGNED-BestPractices-ImageBarrierAccessLayout: 180 in a 30-frame 4x MSAA
clustered scene before, 0 after, image unchanged). A depth resolve is now a
depth-stencil attachment write. Touches neither region of the earlier
qrhivulkan.cpp patches. Not submitted upstream yet.

### qtbase/0011-rhi-metal-skip-generatemips-on-single-level-textures.patch

`-[MTLBlitCommandEncoder generateMipmapsForTexture:]` aborts under the Metal
validation layer on a texture with one mip level (a 1x1 `MipMapped` texture in
the score graphics sweep). The blit is skipped when `mipLevelCount < 2`, which
is what D3D12 and Vulkan effectively do. Not submitted upstream yet.

### qtbase/0012-xcb-egl-pass-an-xlib-window-to-the-x11-platform.patch

On the `EGL_PLATFORM_X11_KHR` path, `QXcbEglWindow::create()` passes
`&m_window`, a pointer to a 32-bit `xcb_window_t`, where the extension expects
a pointer to a 64-bit Xlib `Window`. The upper half is read from the next
member (`m_depth`). The NVIDIA driver rejects the window with
`EGL_BAD_NATIVE_WINDOW`, Qt keeps `EGL_NO_SURFACE`, and every OpenGL window
under `xcb_egl` stays black. Present since 6.7 (12d6fc52291) and still on dev;
drop this once a fix lands upstream.

### qtshadertools/0002-spirv-cross-glsl-viewindex-int-cast.patch

SPIR-V's `ViewIndex` is a signed int, but `GL_OVR_multiview` declares
`gl_ViewID_OVR` as `uint`. SPIRV-Cross's GLSL backend substituted the name
without a cast, so `v_face = gl_ViewIndex;` into an `int` became an implicit
uint-to-int conversion, which NVIDIA's GL compiler rejects (C7011). The patch
loads it as `int(gl_ViewID_OVR)` outside Vulkan semantics. GL only in effect.
Not in upstream SPIRV-Cross yet.
