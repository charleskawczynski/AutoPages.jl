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

This package was designed to provide automation tools for the `pages` keyword in [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)'s `makedocs` method. Our [Tutorials](https://charleskawczynski.github.io/AutoPages.jl/dev/tutorials/home/) are collected with this package, which was configured to be an example itself:

```julia
using Documenter
using AutoPages
using AutoPages: gather_pages, replace_reverse

tutorials_dir = joinpath(@__DIR__, "..", "tutorials") # tutorials directory
mkpath(tutorials_dir)
tutorials, tutorials_list = gather_pages(;
  directory=tutorials_dir,
  extension_filter=x->endswith(x, ".jl"),
  transform_extension=x->replace_reverse(x, ".jl" => ".md"; count=1),
  remove_first_level=true)

makedocs(
    sitename = "AutoPages",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        collapselevel = 1,
        ),
    clean = true,
    modules = [Documenter, AutoPages],
    pages = Any["Home" => "index.md",
                "Tutorials" => tutorials],
)

deploydocs(
    repo = "github.com/charleskawczynski/AutoPages.jl.git",
    target = "build",
)
```
