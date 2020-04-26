using Test
using AutoPages: split_by_camel_case, gather_pages

@testset "Split by CamelCase" begin
    @test split_by_camel_case("AlTeRnAtInG") == ["Al", "Te", "Rn", "At", "In", "G"]

    @test split_by_camel_case("CamelCase") == ["Camel", "Case"]

    @test split_by_camel_case("UPPERThenLowerCase") == ["UPPER", "Then", "Lower", "Case"]

    @test split_by_camel_case("ALLCAPS") == ["ALLCAPS"]

    @test split_by_camel_case("MixOfCASES") == ["Mix", "Of", "CASES"]

    @test split_by_camel_case("LowercasethenUPPERCASE") == ["Lowercasethen", "UPPERCASE"]

    @test split_by_camel_case("DGMethods") == ["DG", "Methods"]
end

function tutorials_list(leading_path_sep)
  return String[
  leading_path_sep * joinpath("path_to", "file1.jl"),
  leading_path_sep * joinpath("path_to", "file2.jl"),
  leading_path_sep * joinpath("path_to", "SubPath1", "SUBPath2", "file3.jl"),
  leading_path_sep * joinpath("path_to", "SubPath1", "SUBPath2", "file4.jl"),
  leading_path_sep * joinpath("path_to", "SubPath1", "SUBPath3", "file5.jl"),
  leading_path_sep * joinpath("path_to", "SubPath1", "SUBPath3", "file6.jl"),
  ]
end

@testset "Pages Array" begin
    for r in ["", Base.Filesystem.path_separator]
        tutorials = tutorials_list(r)

        arr, _ = gather_pages(;filenames=tutorials)

        arr_base = arr[1].second
        @test arr[1].first == "path_to"

        @test arr_base[1].first == "File1"
        @test arr_base[1].second == joinpath("path_to", "file1.jl")
        @test arr_base[2].first == "File2"
        @test arr_base[2].second == joinpath("path_to", "file2.jl")

        @test arr_base[3].first == "Sub Path1"
        @test arr_base[3].second[1].first == "SUB Path2"
        @test arr_base[3].second[2].first == "SUB Path3"

        @test arr_base[3].second[1].second[1].first == "File3"
        @test arr_base[3].second[1].second[2].first == "File4"
        @test arr_base[3].second[2].second[1].first == "File5"
        @test arr_base[3].second[2].second[2].first == "File6"

        @test arr_base[3].second[1].second[1].second == joinpath("path_to", "SubPath1", "SUBPath2", "file3.jl")
        @test arr_base[3].second[1].second[2].second == joinpath("path_to", "SubPath1", "SUBPath2", "file4.jl")
        @test arr_base[3].second[2].second[1].second == joinpath("path_to", "SubPath1", "SUBPath3", "file5.jl")
        @test arr_base[3].second[2].second[2].second == joinpath("path_to", "SubPath1", "SUBPath3", "file6.jl")
    end
end

@testset "Pages Array Remove First Level" begin
    for r in ["", Base.Filesystem.path_separator]
        tutorials = tutorials_list(r)

        arr, _ = gather_pages(;filenames=tutorials, remove_first_level = true)

        arr_base = arr

        @test arr_base[1].first == "File1"
        @test arr_base[1].second == joinpath("path_to", "file1.jl")
        @test arr_base[2].first == "File2"
        @test arr_base[2].second == joinpath("path_to", "file2.jl")

        @test arr_base[3].first == "Sub Path1"
        @test arr_base[3].second[1].first == "SUB Path2"
        @test arr_base[3].second[2].first == "SUB Path3"

        @test arr_base[3].second[1].second[1].first == "File3"
        @test arr_base[3].second[1].second[2].first == "File4"
        @test arr_base[3].second[2].second[1].first == "File5"
        @test arr_base[3].second[2].second[2].first == "File6"

        @test arr_base[3].second[1].second[1].second == joinpath("path_to", "SubPath1", "SUBPath2", "file3.jl")
        @test arr_base[3].second[1].second[2].second == joinpath("path_to", "SubPath1", "SUBPath2", "file4.jl")
        @test arr_base[3].second[2].second[1].second == joinpath("path_to", "SubPath1", "SUBPath3", "file5.jl")
        @test arr_base[3].second[2].second[2].second == joinpath("path_to", "SubPath1", "SUBPath3", "file6.jl")
    end
end
