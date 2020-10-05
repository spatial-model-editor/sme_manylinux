# sme_manylinux2010_x86_64

Docker container for compiling linux python wheels for [sme](https://pypi.org/project/sme/)

- Available from <https://hub.docker.com/repository/docker/lkeegan/sme_manylinux2010_x86_64>

- Used by <https://github.com/spatial-model-editor/spatial-model-editor/blob/master/.travis.yml>

- Based on <https://quay.io/repository/pypa/manylinux2010_x86_64>

- Also copies PyPy binaries from <https://hub.docker.com/r/pypywheels/manylinux2010-pypy_x86_64>

To update:

```bash
docker build . -t lkeegan/sme_manylinux2010_x86_64:tagname
docker push lkeegan/sme_manylinux2010_x86_64:tagname
```

where `tagname` is today's date in the form `YYYY.MM.DD`
