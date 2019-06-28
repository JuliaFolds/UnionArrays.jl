using Documenter, UnionArrays

makedocs(;
    modules=[UnionArrays],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/UnionArrays.jl/blob/{commit}{path}#L{line}",
    sitename="UnionArrays.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/tkf/UnionArrays.jl",
)
