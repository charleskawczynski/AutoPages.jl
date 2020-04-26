# AutoPages.jl

Automatically organize Documenter.jl pages, given a directory or an array of files.

|||
|---------------------:|:----------------------------------------------|
| **Docs Build**       | [![docs build][docs-bld-img]][docs-bld-url]   |
| **Documentation**    | [![dev][docs-dev-img]][docs-dev-url]          |
| **Code Coverage**    | [![codecov][codecov-img]][codecov-url]        |
| **Bors**             | [![Bors enabled][bors-img]][bors-url]         |
| **Travis Build**     | [![travis][travis-img]][travis-url]           |
| **AppVeyor Build**   | [![appveyor][appveyor-img]][appveyor-url]     |

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://charleskawczynski.github.io/AutoPages.jl/dev/

[docs-bld-img]: https://github.com/charleskawczynski/AutoPages.jl/workflows/Documentation/badge.svg
[docs-bld-url]: https://github.com/charleskawczynski/AutoPages.jl/actions?query=workflow%3ADocumentation

[codecov-img]: https://codecov.io/gh/charleskawczynski/AutoPages.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/charleskawczynski/AutoPages.jl

[bors-img]: https://bors.tech/images/badge_small.svg
[bors-url]: https://app.bors.tech/repositories/24499

[travis-img]: https://travis-ci.org/charleskawczynski/AutoPages.jl.svg?branch=master
[travis-url]: https://travis-ci.org/charleskawczynski/AutoPages.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/c6eykd0w94pmyjt8/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/charleskawczynski/autopages-jl/branch/master

## Install

From the Julia Pkg manager:
```julia
(v1.x) pkg> add https://github.com/charleskawczynski/AutoPages.jl
```

## Usage

This package was designed with the intention to be used in `makedocs` in [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl). For example, if you have a folder of [Literate.jl](https://github.com/fredrikekre/Literate.jl) examples in `MyPkg/src/tutorials`, you can use `AutoPages.jl`'s `gather_pages` to create the nested array of `Pair`'s:

```julia
using AutoPages: gather_pages

tutorials, tutorials_list = gather_pages(;
  directory=joinpath(@__DIR__, "..", "tutorials"),
  extension_filter=x->endswith(x, ".jl"),
  remove_first_level=true)

makedocs(
    sitename = "AutoPages",
    format = format,
    clean = true,
    modules = [Documenter, AutoPages],
    pages = Any["Home" => "index.md",
                "Tutorials" => tutorials],
)
```
