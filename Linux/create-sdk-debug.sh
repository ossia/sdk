#!/bin/bash -eux

CPU_ARCH="${CPU_ARCH:-x86_64}"
if [[ "$CPU_ARCH" != "x86_64" ]]; then
  echo "The Linux debug SDK currently supports only x86_64 (got '$CPU_ARCH')" >&2
  exit 1
fi

INSTALL_PREFIX="/opt/ossia-sdk-debug-$CPU_ARCH"
STAGE="${STAGE:-full}"

docker rmi ossia/score-sdk-base-debug || true
docker build --no-cache --pull --compress --force-rm \
  -t ossia/score-sdk-base-debug -f Dockerfile.centos .

IMAGE_ROOT=$(mktemp -d /var/tmp/ossia-sdk-debug-image.XXXXXX)
CONTAINER_NAME="ossia-sdk-debug-build-$CPU_ARCH"
cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  rm -rf "$IMAGE_ROOT"
}
trap cleanup EXIT INT TERM
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
mkdir -p "$IMAGE_ROOT/common" "$INSTALL_PREFIX"
cp -rf . "$IMAGE_ROOT/"
cp -rf ../common/. "$IMAGE_ROOT/common/"

CCACHE_ARGS=()
if [[ -n "${CCACHE_DIR:-}" ]]; then
  mkdir -p "$CCACHE_DIR"
  CCACHE_ARGS+=(
    -e CCACHE_DIR="$CCACHE_DIR"
    -e CCACHE_COMPILERCHECK="${CCACHE_COMPILERCHECK:-content}"
    -e CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-20G}"
    -e CMAKE_C_COMPILER_LAUNCHER="${CMAKE_C_COMPILER_LAUNCHER:-ccache}"
    -e CMAKE_CXX_COMPILER_LAUNCHER="${CMAKE_CXX_COMPILER_LAUNCHER:-ccache}"
    -v "$CCACHE_DIR:$CCACHE_DIR"
  )
fi

docker run --rm --name "$CONTAINER_NAME" \
  -e CPU_ARCH="$CPU_ARCH" \
  -e STAGE="$STAGE" \
  -e NPROC="${NPROC:-8}" \
  "${CCACHE_ARGS[@]}" \
  -v "$IMAGE_ROOT/common:/common" \
  -v "$IMAGE_ROOT:/image" \
  -v "$INSTALL_PREFIX:$INSTALL_PREFIX" \
  -w=/image \
  ossia/score-sdk-base-debug \
  /bin/bash /image/build-all-debug.sh || exit $?

if [[ "${CREATE_ARCHIVE:-1}" == 1 ]]; then
  tar caf "sdk-linux-debug-$CPU_ARCH.tar.xz" "$INSTALL_PREFIX"
fi
