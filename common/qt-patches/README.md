# Local Qt patches

Patches applied to a Qt module after `qt_pick` runs, from
`common/qt-patches/<module>/*.patch`, in filename order. See `qt_apply_local`
in `common/clone-qt.sh`.

Use this for fixes that have no Gerrit change to cherry-pick: not yet submitted
upstream, or submitted and not yet merged. Anything that *does* have a change
belongs in `qt_pick`, which tracks the upstream review instead of a snapshot.

A patch that is already present in the tree is skipped, not an error, so a Qt
bump that picks up the fix upstream does not break the build. Delete the file
when that happens.

## Current patches

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
`QT_ALWAYS_USE_FUTEX` only when the deployment target reaches 14.4, so the
non-futex fallbacks stay compiled in. All `QtFutex` users -- qmutex.cpp,
qsemaphore.cpp, qlatch.cpp, qatomicwait.cpp -- already gate on
`futexAvailable()`, so nothing else needs changing. Machines that do have the
API still take the futex path; the choice is made at runtime.

Not yet submitted to Gerrit. Remove this file once it lands upstream.
