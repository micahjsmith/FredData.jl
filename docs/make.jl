using FredData
using Documenter

DocMeta.setdocmeta!(FredData, :DocTestSetup, :(using FredData); recursive=true)

makedocs(;
    modules=[FredData],
    authors="Micah Smith <micahjsmith@gmail.com>",
    repo="https://github.com/micahjsmith/FredData.jl/blob/{commit}{path}#{line}",
    sitename="FredData.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://micahjsmith.github.io/FredData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/micahjsmith/FredData.jl",
    devbranch="master",
)
