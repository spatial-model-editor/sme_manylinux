# sme_manylinux_x86_64

Docker container for compiling linux x86_64 python wheels for [sme](https://pypi.org/project/sme/)

- Available from <https://ghcr.io/spatial-model-editor/manylinux_x86_64>

- Used by <https://github.com/spatial-model-editor/spatial-model-editor>

- Based on <https://quay.io/repository/pypa/manylinux_2_28_x86_64>

## To update

Update the Dockerfile, tag the commit with `tagname`, git push, then build and push the docker container:

```bash
docker build . -t ghcr.io/spatial-model-editor/manylinux_x86_64:tagname
docker push ghcr.io/spatial-model-editor/manylinux_x86_64:tagname
```

where `tagname` is today's date in the form `YYYY.MM.DD`

## Note

Would be cleaner to have a github action that builds the container on each tagged commit, as we do for sme_deps etc.

Currently not doing this for convenience, as the docker build would take a long time to run on CI.
