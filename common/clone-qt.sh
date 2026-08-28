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

# Apply the local patches we carry for a module, from common/qt-patches/<repo>/.
# These are the fixes that have no Gerrit change to qt_pick -- either not yet
# submitted upstream, or submitted and not yet merged. Applied after the picks
# so they land on top of them.
#
# Same tolerance as qt_pick: a patch already present in the tree (it landed
# upstream and we have not removed the file yet) is success, not failure --
# otherwise every Qt bump would break the build at a random patch. A patch that
# neither applies nor is already applied is a real conflict and does fail.
qt_apply_local() {
  local repo=$1
  local dir="$SDK_COMMON_ROOT/common/qt-patches/$repo"
  [[ -d "$dir" ]] || return 0

  local p
  for p in "$dir"/*.patch; do
    [[ -e "$p" ]] || continue     # nullglob is not set; skip the literal glob
    if git apply --check "$p" 2>/dev/null; then
      git apply "$p"
      echo "clone-qt: applied $(basename "$p") to $repo"
    elif git apply --reverse --check "$p" 2>/dev/null; then
      echo "clone-qt: $(basename "$p") already present in $repo, skipping"
    else
      echo "clone-qt: $(basename "$p") does not apply to $repo at $QT_VERSION" >&2
      return 1
    fi
  done
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

    # qt5.git moves its submodule pointers in batches, so its qtbase trails the
    # 6.12 branch by up to a week -- long enough that fixes we no longer need to
    # carry are still missing from it. Take the branch commit instead.
    git fetch $SDK_FETCH_DEPTH origin "$QTBASE_VERSION"
    git checkout -q FETCH_HEAD

    # The 658xxx changes were abandoned in favour of dev-targeted rewrites; the
    # old refs still resolve, so a stale one builds silently instead of failing.
    # qhash: prevent a -fsanitize=integer warning in the hash functions
    qt_pick qtbase refs/changes/05/757205/2
    # Enable exports on static builds
    qt_pick qtbase refs/changes/66/658066/2
    # qfsm disable sorting
    qt_pick qtbase refs/changes/07/757207/1
    # win32 fontdatabase unity build fix
    qt_pick qtbase refs/changes/04/686804/2
    # QRhiVulkan: swapchain recreated with a stale extent on resize
    qt_pick qtbase refs/changes/71/726771/3

    # RHI changes merged to dev but not present in the pinned 6.12 branch. Keep
    # their dev dependency order: the Metal indirect-count implementation builds
    # on the indirect APIs and render-pass preservation fixes.
    # rhi: Add support for dispatch indirect
    qt_pick qtbase refs/changes/11/738611/16
    # rhi: Add support for multi draw count indirect
    qt_pick qtbase refs/changes/12/738612/19
    # rhi: gl: Implement base instance support
    qt_pick qtbase refs/changes/67/761467/9
    # rhi: metal: Preserve per-pass state when interrupting the render pass
    qt_pick qtbase refs/changes/97/761497/9
    # rhi: metal: Keep attachment contents when interrupting the render pass
    qt_pick qtbase refs/changes/90/761490/10
    # rhi: Implement DrawIndirectCount for Metal, add NoTransientBacking
    qt_pick qtbase refs/changes/69/761469/12
    # rhi: metal: Disable ICB usage when the shader uses textures
    qt_pick qtbase refs/changes/41/763541/4
    # rhi: Add a shader variant for Metal argument buffers
    qt_pick qtbase refs/changes/31/763731/5

    qt_apply_local qtbase
  )

  (
    cd qtshadertools
    git config user.email "you@example.com"
    git config user.name "Your Name"

    # Keep shader tools at its own 6.12 head, in lockstep with qtbase.
    git fetch $SDK_FETCH_DEPTH origin "$QTSHADERTOOLS_VERSION"
    git checkout -q FETCH_HEAD

    # Generate the MSL argument-buffer variant declared by the qtbase pick.
    qt_pick qtshadertools refs/changes/32/763732/2

    qt_apply_local qtshadertools
  )

  (
    cd qtdeclarative
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # cmake: do not try to use qmlcachegen if it is not being built
    qt_pick qtdeclarative refs/changes/68/464668/2
    # masm: PATH_MAX used with no limits.h in scope
    qt_pick qtdeclarative refs/changes/04/757204/1

    qt_apply_local qtdeclarative
  )

  (
    cd qtquick3d/src/3rdparty/assimp/src
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # assimp missing ostream
    qt_pick qtquick3d-assimp refs/changes/32/687132/2

  )

  (
    cd qtquick3d
    qt_apply_local qtquick3d
  )
)
fi
