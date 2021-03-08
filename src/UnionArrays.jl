module UnionArrays

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest README")
end UnionArrays

function buffereltypefor end
function buffereltypeof end

include("abstract/abstract.jl")
include("impl/impl.jl")

Abstract.UnionVector(args...; kwargs...) = Impl.UnionVector(args...; kwargs...)
Abstract.UnionArray(args...; kwargs...) = Impl.UnionArray(args...; kwargs...)

using .Abstract: UnionArray, UnionVector, UnionMatrix
export UnionArray, UnionVector, UnionMatrix

end # module
