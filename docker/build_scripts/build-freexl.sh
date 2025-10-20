#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${FREEXL_ROOT}"
check_var "${FREEXL_DOWNLOAD_URL}"

# fetch the sources and install
fetch_source "${FREEXL_ROOT}.tar.gz" "$FREEXL_DOWNLOAD_URL"
tar -xzf "${FREEXL_ROOT}.tar.gz"
pushd "${FREEXL_ROOT}"
# Update config.guess and config.sub for aarch64 support
if [ -f /usr/share/automake-*/config.guess ]; then
	cp -f /usr/share/automake-*/config.guess .
	cp -f /usr/share/automake-*/config.sub .
fi
./configure
make -j$(nproc)
DESTDIR=/manylinux-rootfs make install
popd

rm -rf "${FREEXL_ROOT}.tar.gz" "${FREEXL_ROOT}"

# Strip what we can
strip_ /manylinux-rootfs

hash -r
