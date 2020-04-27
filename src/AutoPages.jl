module AutoPages

export gather_pages

function replace_reverse(x, p...; count::Union{Integer,Nothing}=nothing)
  from = getproperty.(p, :first)
  to = getproperty.(p, :second)
  reversed_pairs = Pair.(reverse.(from), reverse.(to))
  x_reversed = reverse(x)
  if count==nothing
    return String(collect(Iterators.reverse(replace(x_reversed, reversed_pairs...))))
  else
    return String(collect(Iterators.reverse(replace(x_reversed, reversed_pairs...; count=count))))
  end
end

if Sys.isunix()
    const path_separator = '/'
elseif Sys.iswindows()
    const path_separator = '\\'
else
    error("path_separator for this OS need to be defined")
end

"""
    transform_page(filename)

Transform filename to title
seen in the navigation panel.
"""
function transform_page(filename)
  titlename = String(first(splitext(filename)))
  titlename = replace(titlename, "_" => " ")
  titlename = titlecase(titlename)
  return titlename
end

"""
    transform_subpage(local_path)

Transform local path to sub-page
title, seen in the navigation panel.
"""
function transform_subpage(local_path)
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
    gather_pages!(array::Array,
                  filename,
                  folders_with_only_files,
                  fullpath = dirname(filename))

Construct a nested array of `Pair`s whose
keys mirror the given folder structure and
values which point to the files.
"""
function gather_pages!(
    array::Array,
    filename::S,
    folders_with_only_files::Vector{S},
    transform_page::Function,
    transform_subpage::Function,
    fullpath = dirname(filename),
) where {S<:AbstractString}
    paths = splitpath(filename)
    if length(paths) == 1
        file = paths[1]
        titlename = transform_page(file)
        push!(array, Pair(String(titlename), String(joinpath(fullpath, file))))
    else
        local_path = paths[1]
        key = transform_subpage(local_path)
        file_next = joinpath(paths[2:end]...)
        if !any(x.first == key for x in array)
            push!(array, Pair(key, Any[]))
        end
        arr_next = array[end].second
        gather_pages!(arr_next,
                      file_next,
                      folders_with_only_files,
                      transform_page,
                      transform_subpage,
                      fullpath)
    end
end

"""
    gather_pages(filenames::Array;
                 remove_first_level::Bool = false,
                 transform_page::Function=transform_page,
                 transform_subpage::Function=transform_subpage)

Construct a nested array of `Pair`s whose
keys mirror the given folder structure and
values which point to the files.

This was specifically designed for
Documenter.jl's `page` array.
See the tests for an example.

 - `directory` to get filenames from walk
 - `filenames` Array of `.md` files (using relative paths)
 - `remove_first_level` Bool indicating whether or not
                        to remove the root directory
                        (e.g., `generated/`)
 - `transform_page` function to transform the page (title) in navigation panel
 - `transform_subpage` function to transform the sub-page in navigation panel
 - `extension_filter` filter extensions
 - `transform_extension` transform extensions (e.g., ".jl" to ".md")
                         a useful one is `AutoPages.replace_reverse(x, ".jl" => ".md"; count=1)`
 - `transform_path` transform path
"""
function gather_pages(;
    directory::Union{AbstractString,Nothing}=nothing,
    filenames::Union{Array,Nothing}=nothing,
    remove_first_level::Bool = false,
    transform_page::Function=transform_page,
    transform_subpage::Function=transform_subpage,
    extension_filter=x->endswith(x, ".md"),
    transform_extension=x->x,
    transform_path=x->x,
    )

    if filenames === nothing && directory === nothing
      throw(ArgumentError("Need filenames or directory keyword"))
    end
    if filenames ≠ nothing && directory ≠ nothing
      throw(ArgumentError("Too many kwargs given"))
    end

    if directory ≠ nothing
      filenames = [String(joinpath(r, f)) for (r, _, files) in Base.Filesystem.walkdir(directory) for f in files]
      filenames = filter(extension_filter, filenames)
      filenames = map(x -> String(last(split(x, dirname(directory)))), filenames)
    end

    filenames = map(x -> transform_extension(x), filenames)
    filter!(x -> !(x == path_separator), filenames)
    filenames = map(x -> String(lstrip(x, path_separator)), filenames)
    filenames = map(x -> transform_path(x), filenames)
    dirnames = collect(Set(dirname.(filenames)))

    # TODO: Might be able to improve performance here
    dirnames = [x for x in dirnames if !any(occursin(x, y) && !(x == y) for y in dirnames)]
    folders_with_only_files = basename.(dirnames)
    array = Any[]
    for file in filenames
        gather_pages!(array,
                      file,
                      folders_with_only_files,
                      transform_page,
                      transform_subpage)
    end

    if remove_first_level
        array = array[1].second
    end

    return array, filenames
end

end