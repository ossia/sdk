#!/bin/bash -eu

source ./common.sh

brew update

# NB: no blanket `brew upgrade`. It upgrades everything the runner image happens
# to ship -- chrome, edge, aws-sam-cli, ruby -- none of which this SDK builds
# against, and it fails the whole job when one of those cannot be relinked over
# preinstalled files (ruby@3.3, 2026-07-20). `brew install` below still pulls in
# whatever its own formulae need.
# NB: no glslang here, unlike Linux/Dockerfile.centos and MSYS/deps.sh. ffmpeg
# only probes for a SPIR-V compiler inside `if enabled vulkan`, and macOS does
# not enable vulkan -- that would mean shipping MoltenVK, a real runtime
# dependency, where VideoToolbox already covers Apple hardware. So glslang would
# be installed and never used.
brew install cmake ninja boost gnu-tar gnu-sed yasm nasm subversion meson pkg-config ccache xz

SDK_DIR=.


