# sme_manylinux2014_x86_64

Docker container for compiling linux python wheels for [sme](https://pypi.org/project/sme/)

- Available from <https://ghcr.io/spatial-model-editor/manylinux2014_x86_64>

- Used by <https://github.com/spatial-model-editor/spatial-model-editor>

- Based on <https://quay.io/repository/pypa/manylinux2014_x86_64>

To update:

```bash
docker build . -t ghcr.io/spatial-model-editor/manylinux2014_x86_64:tagname
docker push ghcr.io/spatial-model-editor/manylinux2014_x86_64:tagname
```

where `tagname` is today's date in the form `YYYY.MM.DD`
