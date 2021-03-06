using Documenter
using AutoPages
using AutoPages: gather_pages, replace_reverse, transform_page

tutorials_dir = joinpath(@__DIR__, "..", "tutorials") # tutorials directory
mkpath(tutorials_dir)
tutorials, tutorials_list = gather_pages(;
  directory=tutorials_dir,
  extension_filter=x->endswith(x, ".jl"),
  transform_extension=x->replace_reverse(x, ".jl" => ".md"; count=1),
  remove_first_level=true)

# #### Let's suppose we've used Literate to generate markdown:
# for tutorial in tutorials_list
#     mkpath(joinpath(@__DIR__,"src",dirname(tutorial)))
# end
# for tutorial in tutorials_list
#     title = transform_page(basename(tutorial))
#     open(joinpath(@__DIR__,"src",tutorial), "w") do io
#     print(io, "# $(title)")
#     end
# end
# ####

format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        collapselevel = 1,
        )

makedocs(
    sitename = "AutoPages",
    format = format,
    clean = true,
    modules = [Documenter, AutoPages],
    pages = Any["Home" => "index.md",
                "Tutorials" => tutorials],
)

deploydocs(
    repo = "github.com/charleskawczynski/AutoPages.jl.git",
    target = "build",
)
