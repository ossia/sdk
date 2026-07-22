#!/bin/bash -eu

source ./common.sh

brew update

# NB: no blanket `brew upgrade`. It upgrades everything the runner image happens
# to ship -- chrome, edge, aws-sam-cli, ruby -- none of which this SDK builds
# against, and it fails the whole job when one of those cannot be relinked over
# preinstalled files (ruby@3.3, 2026-07-20). `brew install` below still pulls in
# whatever its own formulae need.
brew install cmake ninja boost gnu-tar gnu-sed yasm nasm subversion meson pkg-config ccache xz

SDK_DIR=.


