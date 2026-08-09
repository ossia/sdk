#!/bin/bash

source ../common/versions.sh

# git 2.55 races on a shallow repo's .git/shallow: when a `fetch --depth` runs
# next to git's background maintenance (commit-graph / auto-gc), the fetch reads
# a shallow file whose stat changed underneath it and aborts with
#   fatal: shallow file has changed since we read it
# Our Qt picks are exactly this pattern -- a dozen `fetch --depth 2` in a row on
# a shallow clone -- and it took down every git-2.55 leg (all of macOS + Windows;
# Linux on 2.54 was immune) at a different, random pick each run. Stop git from
# mutating .git/shallow behind our back. Global is fine: this is a CI checkout.
git config --global gc.auto 0
git config --global fetch.writeCommitGraph false
git config --global maintenance.auto false

# Apply a Gerrit change to the repo we are currently in.
#
# We carry a dozen-odd unmerged changes against a moving Qt branch, so a change
# regularly stops being a change: it lands upstream, or gets listed here twice.
# Either way the cherry-pick comes out empty, and plain `git cherry-pick` then
# stops mid-operation and exits 1 -- which used to take down every core leg at
# once. Nothing left to apply is success; keep going. A real conflict still
# fails hard, because that one does need a human.
qt_pick() {
  local repo=$1 ref=$2 i ok=0
  local url="https://codereview.qt-project.org/qt/$repo"
  # Retry the fetch: the shallow-file race above is transient (a second read
  # sees a settled file), so a retry clears it; a genuine network/ref error
  # still gives up after five tries rather than cherry-picking a stale FETCH_HEAD.
  for i in 1 2 3 4 5; do
    if git fetch $SDK_FETCH_DEPTH "$url" "$ref"; then ok=1; break; fi
    echo "clone-qt: fetch of $repo $ref failed (try $i/5); retrying" >&2
    sleep $((i * 2))
  done
  if [[ $ok -eq 0 ]]; then
    echo "clone-qt: fetch of $repo $ref failed after 5 tries" >&2
    return 1
  fi
  if git cherry-pick --keep-redundant-commits FETCH_HEAD; then
    return 0
  fi
  git cherry-pick --abort || true
  echo "clone-qt: cherry-pick of $repo $ref conflicts with $QT_VERSION" >&2
  return 1
}

if [[ ! -d qt ]]; then
# $QT_VERSION is a super-repo SHA, so this cannot be `clone -b`: that only takes
# a branch or tag name. Fetch the commit directly instead -- allowed by both
# github.com and code.qt.io, and it works with --depth 1.
git init -q qt
(
  cd qt
  git remote add origin https://github.com/qt/qt5
  git fetch $SDK_CLONE_DEPTH origin $QT_VERSION
  git checkout -q FETCH_HEAD
)

(
  cd qt
  git submodule update --init --recursive $SDK_CLONE_DEPTH $(cat "$SDK_COMMON_ROOT/common/qtmodules")

  (
    cd qtbase
    git config user.email "you@example.com"
    git config user.name "Your Name"

    # The 658xxx changes were abandoned in favour of dev-targeted rewrites; the
    # old refs still resolve, so a stale one builds silently instead of failing.
    # qarraydata: prevent a -fsanitize=integer warning
    qt_pick qtbase refs/changes/00/757200/1
    # qhash: same, for the hash functions themselves
    qt_pick qtbase refs/changes/05/757205/2
    # Enable exports on static builds
    qt_pick qtbase refs/changes/66/658066/2
    # link to brotlicommon
    qt_pick qtbase refs/changes/02/757202/1
    # qfsm disable sorting
    qt_pick qtbase refs/changes/07/757207/1
    # qsimd.cpp: add missing stdlib.h for getenv -- merged upstream (6.11/dev), now in 6.12.0
    # win32 fontdatabase unity build fix
    qt_pick qtbase refs/changes/04/686804/2
    # win32 Font api clash
    qt_pick qtbase refs/changes/05/686805/2

    # These three were in-place perl rewrites until they went upstream; they are
    # ordinary picks now, so nothing here edits Qt sources with a regex any more.
    # QTipLabel::styleSheetParentDestroyed() unguarded (-no-feature-style-stylesheet)
    qt_pick qtbase refs/changes/16/757216/1
    # windows.graphics.display.interop.h is Windows-SDK-only, mingw-w64 lacks it
    qt_pick qtbase refs/changes/17/757217/1
    # .symver version nodes are undefined in a static link, lld rejects them
    qt_pick qtbase refs/changes/18/757218/1

    # macos crashes when a QNSView outlives its QCocoaWindow (screen off/on,
    # embedding hosts). Supersedes the old 729289 pick.
    qt_pick qtbase refs/changes/09/757209/3
    # QRhiVulkan: swapchain recreated with a stale extent on resize
    qt_pick qtbase refs/changes/71/726771/3
  )

  (
    cd qtdeclarative
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # cmake: do not try to use qmlcachegen if it is not being built
    qt_pick qtdeclarative refs/changes/68/464668/2
    # masm: PATH_MAX used with no limits.h in scope
    qt_pick qtdeclarative refs/changes/04/757204/1
  )

  (
    cd qtquick3d/src/3rdparty/assimp/src
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # assimp missing ostream
    qt_pick qtquick3d-assimp refs/changes/32/687132/2

  )
)
fi
