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

### qtdeclarative/0001-qmlmodels-adapt-compare-data-overload.patch

The qtbase 6.12 head replaced its nullable `QCollator` pointer overload with
reference and no-collator overloads before qtdeclarative was adapted. Keep the
submodule heads buildable together until the matching qtdeclarative change
lands.

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
