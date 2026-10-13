# sme_manylinux

Docker containers for compiling linux python wheels for [sme](https://pypi.org/project/sme/)

- Available from <https://ghcr.io/spatial-model-editor/sme_manylinux>

- Used by <https://github.com/spatial-model-editor/spatial-model-editor>

- Based on
  - <https://quay.io/repository/pypa/manylinux_2_28_x86_64>
  - <https://quay.io/repository/pypa/manylinux_2_28_aarch64>

## To update

To release new images, tag the commit with `YYYY.MM.DD`

Library versions in `Dockerfile` should be kept aligned with
[`sme_deps_common`](https://github.com/spatial-model-editor/sme_deps_common/blob/main/.github/workflows/release.yml)
and [`sme_deps`](https://github.com/spatial-model-editor/sme_deps/blob/main/.github/workflows/release.yml).
Qt and zlib versions come from
[`sme_deps_qt`](https://github.com/spatial-model-editor/sme_deps_qt/blob/main/.github/workflows/release.yml).
