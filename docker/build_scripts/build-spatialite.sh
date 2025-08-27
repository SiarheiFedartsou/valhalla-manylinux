#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${SPATIALITE_ROOT}"
check_var "${SPATIALITE_DOWNLOAD_URL}"

# fetch the sources and install
fetch_source "${SPATIALITE_ROOT}.tar.gz" "$SPATIALITE_DOWNLOAD_URL"
tar -xzf "${SPATIALITE_ROOT}.tar.gz"
pushd "${SPATIALITE_ROOT}"
./configure
make -j$(nproc)
DESTDIR=/manylinux-rootfs make install
popd

rm -rf "${SPATIALITE_ROOT}.tar.gz" "$SPATIALITE_ROOT"

# Strip what we can
strip_ /manylinux-rootfs

hash -r
