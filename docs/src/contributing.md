# Contributing

Contributions are welcome. Interested in contributing to FredData? Please check out [open issues](https://github.com/micahjsmith/FredData.jl/issues) or [create a new issue](https://github.com/micahjsmith/FredData.jl/issues).

I'm using Julia less these days unfortunately, so I am very open to others who find FredData useful to join as maintainers.  Please [contact me](https://www.micahsmith.com/contact/) if you think this applies to you.

## Dev install

```
julia -e '
    using Pkg
    Pkg.develop(PackageSpec(path=pwd()))
    Pkg.instantiate()'
```

## Running tests

```
julia test/runtests.jl
```

Note you need a FRED API key available on your test machine to run integration tests.

## Building documentation

Install docs dependencies

```
julia --project=docs -e '
    using Pkg
    Pkg.develop(PackageSpec(path=pwd()))
    Pkg.instantiate()'
```

Build docs

```
julia --project=docs docs/make.jl
```

Serve docs at `http://localhost:8000`

```
python -m http.server --bind localhost --directory ./docs/build 8000
```

## Release

* create commit on master that changes version number
* comment on commit `@JuliaRegistrator register`
* after new version is merged in Julia registry, push tag
* TagBot should create new release in GitHub repo after new version is available in registry
