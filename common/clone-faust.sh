#!/bin/bash -eu

source ../common/versions.sh

FAUST_REPO=https://github.com/grame-cncm/faust
FAUST_PATCHES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/faust-patches" && pwd)"

# Backend selection written to faust/build/backends/llvm.cmake. Platforms that
# need a different set (WASM) assign FAUST_BACKENDS before sourcing this file.
if [[ -z "${FAUST_BACKENDS:-}" ]]; then
FAUST_BACKENDS='
set ( INCLUDE_LLVM_STATIC_IN_ARCHIVE OFF )
set ( ASMJS_BACKEND  OFF CACHE STRING  "Include ASMJS backend" FORCE )
set ( C_BACKEND      COMPILER STATIC DYNAMIC        CACHE STRING  "Include C backend"         FORCE )
set ( CPP_BACKEND    COMPILER STATIC DYNAMIC        CACHE STRING  "Include CPP backend"       FORCE )
set ( FIR_BACKEND    OFF        CACHE STRING  "Include FIR backend"       FORCE )
set ( INTERP_BACKEND OFF        CACHE STRING  "Include INTERPRETER backend" FORCE )
set ( JAVA_BACKEND   OFF        CACHE STRING  "Include JAVA backend"      FORCE )
set ( JS_BACKEND     OFF        CACHE STRING  "Include JAVASCRIPT backend" FORCE )
set ( LLVM_BACKEND   COMPILER STATIC DYNAMIC        CACHE STRING  "Include LLVM backend"      FORCE )
set ( OLDCPP_BACKEND OFF        CACHE STRING  "Include old CPP backend"   FORCE )
set ( RUST_BACKEND   OFF        CACHE STRING  "Include RUST backend"      FORCE )
set ( WASM_BACKEND   OFF   CACHE STRING  "Include WASM backend"  FORCE )
'
fi

# Apply one of $FAUST_PRS on top of $FAUST_VERSION. Run from inside the clone.
faust_pick() {
  local pr=$1
  echo "clone-faust: applying PR #$pr"
  git fetch $SDK_FETCH_DEPTH "$FAUST_REPO" "refs/pull/$pr/head"
  # Once a PR lands upstream and FAUST_VERSION moves past it the pick comes out
  # empty. That is success, not a conflict, so keep going. A real conflict still
  # fails hard, because that one does need a human.
  git cherry-pick --keep-redundant-commits FETCH_HEAD
}

if [[ ! -d faust ]]; then
(
  set -e
  git clone --recursive -j4 $SDK_CLONE_DEPTH $SDK_SHALLOW_SUBMODULES "$FAUST_REPO"
  cd faust

  # FAUST_VERSION is a commit, not a tag, so it cannot be cloned with -b, and a
  # shallow clone only carries the tip of the default branch.
  git fetch $SDK_FETCH_DEPTH origin "$FAUST_VERSION"
  git checkout "$FAUST_VERSION"
  git submodule update --init --recursive

  # cherry-pick refuses to run without a committer identity.
  git config user.email "you@example.com"
  git config user.name "Your Name"

  for pr in ${FAUST_PRS:-}; do
    faust_pick "$pr"
  done

  for p in "$FAUST_PATCHES_DIR"/*.patch; do
    [[ -e "$p" ]] || continue
    if git apply --check "$p" 2>/dev/null; then
      git apply "$p"
      echo "clone-faust: applied $(basename "$p")"
    elif git apply --reverse --check "$p" 2>/dev/null; then
      echo "clone-faust: $(basename "$p") already present, skipping"
    else
      echo "clone-faust: $(basename "$p") does not apply to $FAUST_VERSION" >&2
      exit 1
    fi
  done
)
fi

echo "$FAUST_BACKENDS" > faust/build/backends/llvm.cmake
