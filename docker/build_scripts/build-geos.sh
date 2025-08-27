#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${GEOS_ROOT}"
check_var "${GEOS_DOWNLOAD_URL}"

# fetch the sources and install
fetch_source "${GEOS_ROOT}.tar.bz2" "$GEOS_DOWNLOAD_URL"
tar -xf "${GEOS_ROOT}.tar.bz2"
pushd "${GEOS_ROOT}"
cmake -B build -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_TESTING=OFF .
make -C build -j$(nproc)
DESTDIR=/manylinux-rootfs make -C build install
popd

rm -rf "${GEOS_ROOT}.tar.bz2" "$GEOS_ROOT"

hash -r
