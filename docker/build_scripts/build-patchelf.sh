#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${PATCHELF_ROOT}"
check_var "${PATCHELF_GIT_URL}"

# remove system patchelf first
manylinux_pkg_remove patchelf

# fetch the sources and install
PATCHELF_COMMIT=${PATCHELF_ROOT#*-}
git clone --recurse-submodules -j$(nproc) ${PATCHELF_GIT_URL} ${PATCHELF_ROOT}
pushd "${PATCHELF_ROOT}"
git checkout ${PATCHELF_COMMIT}
./bootstrap.sh
DESTDIR=/manylinux-rootfs do_standard_install
popd
rm -rf "${PATCHELF_ROOT}"

# Strip what we can
strip_ /manylinux-rootfs

# Install
cp -rlf /manylinux-rootfs/* /

hash -r
