using Documenter, UnionArrays

makedocs(;
    modules=[UnionArrays],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/JuliaFolds/UnionArrays.jl/blob/{commit}{path}#L{line}",
    sitename="UnionArrays.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
)

deploydocs(;
    repo="github.com/JuliaFolds/UnionArrays.jl",
    push_preview = true,
)
