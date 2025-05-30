#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

check_var "${BOOST_ROOT}"
check_var "${BOOST_HASH}"
check_var "${BOOST_DOWNLOAD_URL}"

# fetch the sources and install
fetch_source "${BOOST_ROOT}-b2-nodocs.tar.gz" "${BOOST_DOWNLOAD_URL}"
check_sha256sum "${BOOST_ROOT}-b2-nodocs.tar.gz" "${BOOST_HASH}"
tar -xzf "${BOOST_ROOT}-b2-nodocs.tar.gz"
# we only install the headers (way too many, but too lazy to properly filter them)
mkdir -p /manylinux-rootfs/usr/local/include
cp -rf "${BOOST_ROOT}/boost" /manylinux-rootfs/usr/local/include

rm -rf "${BOOST_ROOT}" "${BOOST_ROOT}-b2-nodocs.tar.gz"

# Install
cp -rlf /manylinux-rootfs/* /

hash -r
