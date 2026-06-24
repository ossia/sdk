#!/bin/bash -eux
#export DOCKER_BUILDKIT=1

# Build stage: core | media | full (default). 'media' expects the core SDK to
# already be extracted into /opt/ossia-sdk-$CPU_ARCH (the workflow does that
# before calling this script); the docker bind-mount below makes it visible in
# the container at the same path, so media compiles against the core's clang.
STAGE="${STAGE:-full}"

docker rmi ossia/score-sdk-base || true
# NB: --squash needs a daemon with experimental features and is rejected by
# modern Docker/BuildKit, so it is not used here (it only shrank the base image,
# not the produced SDK).
docker build --no-cache --pull --compress --force-rm -t ossia/score-sdk-base -f Dockerfile.centos .

mkdir -p /tmp/image
mkdir -p /opt/ossia-sdk-$CPU_ARCH
cp -rf * /tmp/image/
cp -rf ../common/* /tmp/image/common/

# Forward ccache into the container when CCACHE_DIR is set (CI). CMake picks up
# CMAKE_<LANG>_COMPILER_LAUNCHER from the environment, so every cmake-based step
# (LLVM, Qt, ...) is cached; harmless no-op when unset (local runs).
CCACHE_ARGS=()
if [[ -n "${CCACHE_DIR:-}" ]]; then
  mkdir -p "$CCACHE_DIR"
  CCACHE_ARGS+=(
    -e CCACHE_DIR="$CCACHE_DIR"
    -e CCACHE_COMPILERCHECK="${CCACHE_COMPILERCHECK:-content}"
    -e CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-3G}"
    -e CMAKE_C_COMPILER_LAUNCHER="${CMAKE_C_COMPILER_LAUNCHER:-ccache}"
    -e CMAKE_CXX_COMPILER_LAUNCHER="${CMAKE_CXX_COMPILER_LAUNCHER:-ccache}"
    -v "$CCACHE_DIR:$CCACHE_DIR"
  )
fi

# No -it: must stay non-interactive so it works under CI.
docker run --rm \
-e CPU_ARCH="$CPU_ARCH" \
-e STAGE="$STAGE" \
-e CI="${CI:-}" \
"${CCACHE_ARGS[@]}" \
-v "/tmp/image/common:/common" \
-v "/tmp/image:/image" \
-v "/opt/ossia-sdk-$CPU_ARCH:/opt/ossia-sdk-$CPU_ARCH" \
-w="/image" \
ossia/score-sdk-base \
/bin/bash /image/build-all-release.sh

if [[ "$STAGE" == "core" ]]; then
  # Ship only the core-owned top-level dirs (allowlist); media is added later.
  core_paths=()
  for d in llvm qt6-static openssl sysroot; do
    [[ -e "/opt/ossia-sdk-$CPU_ARCH/$d" ]] && core_paths+=("/opt/ossia-sdk-$CPU_ARCH/$d")
  done
  tar caf sdk-core-linux-$CPU_ARCH.tar.xz "${core_paths[@]}"
else
  # media/full: the whole merged prefix is the shippable SDK (unchanged name).
  tar caf sdk-linux-$CPU_ARCH.tar.xz /opt/ossia-sdk-$CPU_ARCH
fi
