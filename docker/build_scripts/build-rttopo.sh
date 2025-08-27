#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${RTTOPO_ROOT}"
check_var "${RTTOPO_DOWNLOAD_URL}"

# fetch the sources and install
fetch_source "${RTTOPO_ROOT}.tar.gz" "$RTTOPO_DOWNLOAD_URL"
tar -xzf "${RTTOPO_ROOT}.tar.gz"
pushd "librttopo-${RTTOPO_ROOT}"
./autogen.sh
./configure
make -j$(nproc)
DESTDIR=/manylinux-rootfs make install
popd

rm -rf "${RTTOPO_ROOT}.tar.gz" "librttopo-${RTTOPO_ROOT}"

# Strip what we can
strip_ /manylinux-rootfs

hash -r
