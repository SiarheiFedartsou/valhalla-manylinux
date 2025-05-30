## `manylinux` base image to build Valhalla's Python bindings

Currently based on https://github.com/pypa/manylinux/commits/96ea22a88cf1f5228a7ed2c232dc314a1e216234.

Adaptations:

- `finalize.sh`: keep python static libraries so we can use them during the build
- `install-runtime-packages`: install all dependencies to the image for Valhalla (`valhalla_python` branch)
- `build_sqlite3.sh`: add `-DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA` to build for GDAL & spatialite
- build & install a few packages from source and register them in the `Dockerfile`:
  - `build-prime_server.sh`
  - `build-protobuf.sh`: `dnf` would install 3.5.0, I guess that was troublesome, can't remember..
  - `build-boost.sh`: `dnf` would install 1.66, while we require min 1.71
  - `build-geos.sh`: `dnf` would install 3.7.2, which didn't install a `.pc` file
  - `install-cmake.sh`: needed to build above packages

### Local builds

1. Make sure you have a `docker buildx` backend which can handle local caching etc.
    ```shell
    docker buildx create --name builder-docker-container --driver docker-container
    docker buildx inspect --bootstrap --builder builder-docker-container
    ```
2. Build the image with the new driver
    ```shell
    POLICY=manylinux_2_28 PLATFORM=x86_64 COMMIT_SHA=$(git rev-parse --verify HEAD) BUILDX_BUILDER=builder-docker-container ./build.sh
    ```

That will create an image called `quay.io/pypa/manylinux_2_28_x86_64:$(git rev-parse --verify HEAD)`.
