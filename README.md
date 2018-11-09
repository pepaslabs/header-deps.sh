# header-deps.sh

A "package manager" for single-file C libraries.

To use this script, list your dependencies in a `header-deps.txt` file in your current directory and then run `header-deps.sh`.

Here is an example `header-deps.txt`:

```
stb.h
stb_perlin.h
```

Depedencies are resolved against [header-libs.txt](https://raw.githubusercontent.com/pepaslabs/header-deps.sh/master/header-libs.txt).  Pull-requests against this file are welcome!
