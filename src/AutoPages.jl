module AutoPages

if Sys.isunix()
    const path_separator = '/'
elseif Sys.iswindows()
    const path_separator = '\\'
else
    error("path_separator for this OS need to be defined")
end

"""
    transform_file(filename)

Transform filename to title
seen in the navigation panel.
"""
function transform_file(filename)
  titlename = String(first(splitext(filename)))
  titlename = replace(titlename, "_" => " ")
  titlename = titlecase(titlename)
  return titlename
end

"""
    transform_path(local_path)

Transform local path to sub-page
title, seen in the navigation panel.
"""
function transform_path(local_path)
  return join(split_by_camel_case(local_path), " ")
end

"""
    split_by_camel_case(s::AbstractString)

Splits a string into an array of strings,
by its `CamelCase`. Examples:

```julia
julia> split_by_camel_case("CamelCase")
2-element Array{SubString{String},1}:
 "Camel"
 "Case"
julia> split_by_camel_case("PDESolver")
2-element Array{SubString{String},1}:
 "PDE"
 "Solver"
```
"""
split_by_camel_case(obj::AbstractString) =
    split(obj, r"((?<=\p{Ll})(?=\p{Lu})|(?<=\p{Lu})(?=\p{Lu}[^\p{Lu}]+))")

"""
    pages_array!(
        array::Array,
        filename,
        folders_with_only_files,
        fullpath = dirname(filename))

Construct a nested array of `Pair`s whose
keys mirror the given folder structure and
values which point to the files.
"""
function pages_array!(
    array::Array,
    filename::S,
    folders_with_only_files::Vector{S},
    transform_file::Function,
    transform_path::Function,
    fullpath = dirname(filename),
) where {S<:AbstractString}
    paths = splitpath(filename)
    if length(paths) == 1
        file = paths[1]
        titlename = transform_file(file)
        push!(array, Pair(String(titlename), String(joinpath(fullpath, file))))
    else
        local_path = paths[1]
        key = transform_path(local_path)
        file_next = joinpath(paths[2:end]...)
        if !any(x.first == key for x in array)
            push!(array, Pair(key, Any[]))
        end
        arr_next = array[end].second
        pages_array!(arr_next,
                     file_next,
                     folders_with_only_files,
                     transform_file,
                     transform_path,
                     fullpath)
    end
end

"""
    pages_array(filenames::Array{AbstractString};
                remove_first_level::Bool = false)

Construct a nested array of `Pair`s whose
keys mirror the given folder structure and
values which point to the files.

This was specifically designed for
Documenter.jl[^1]'s `page` array.
See the tests for an example.

 - `filenames` Array of `.md` files (relative path)
 - `remove_first_level` Bool indicating whether or not
                        to remove the root directory
                        (e.g., `generated/`)

[^1]: https://github.com/JuliaDocs/Documenter.jl
"""
function pages_array(
    filenames::Array;
    remove_first_level::Bool = false,
    transform_file::Function=transform_file,
    transform_path::Function=transform_path
    )

    filter!(x -> !(x == path_separator), filenames)

    filenames = map(x -> String(lstrip(x, path_separator)), filenames)

    dirnames = collect(Set(dirname.(filenames)))

    # TODO: Can this be improved?
    dirnames = [x for x in dirnames if !any(occursin(x, y) && !(x == y) for y in dirnames)]

    folders_with_only_files = basename.(dirnames)

    array = Any[]
    for file in filenames
        pages_array!(array,
                     file,
                     folders_with_only_files,
                     transform_file,
                     transform_path)
    end

    if remove_first_level
        array = array[1].second
    end

    return array
end

end