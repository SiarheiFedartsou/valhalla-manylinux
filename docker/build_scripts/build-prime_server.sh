#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${PRIME_ROOT}"
check_var "${PRIME_GIT_URL}"

# fetch the sources and install
PRIME_VERSION=${PRIME_ROOT#*-}
git clone --recurse-submodules -j$(nproc) ${PRIME_GIT_URL} ${PRIME_ROOT}
pushd "${PRIME_ROOT}"
git checkout ${PRIME_VERSION}
cmake -B build -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DENABLE_WALL=OFF -DENABLE_WERROR=OFF .
make -C build -j$(nproc)
DESTDIR=/manylinux-rootfs make -C build install
popd
rm -rf "${PRIME_ROOT}"

# Strip what we can
strip_ /manylinux-rootfs

hash -r
