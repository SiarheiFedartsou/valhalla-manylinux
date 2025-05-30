#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${PROTOBUF_ROOT}"
check_var "${PROTOBUF_DOWNLOAD_URL}"

PROTOBUF_TAR_GZ=$(basename "$PROTOBUF_DOWNLOAD_URL")
PROTOBUF_URL_BASE=$(dirname "$PROTOBUF_DOWNLOAD_URL")

# fetch the sources and install
fetch_source "$PROTOBUF_TAR_GZ" "$PROTOBUF_URL_BASE"
tar -xzf "${PROTOBUF_TAR_GZ}"
pushd "${PROTOBUF_ROOT}"
cmake -B build -DCMAKE_POSITION_INDEPENDENT_CODE=ON -Dprotobuf_BUILD_TESTS=OFF .
make -C build -j$(nproc)
DESTDIR=/manylinux-rootfs make -C build install
popd

rm -rf "$PROTOBUF_TAR_GZ" "$PROTOBUF_ROOT"

# Strip what we can
strip_ /manylinux-rootfs

# Install
cp -rlf /manylinux-rootfs/* /

hash -r
