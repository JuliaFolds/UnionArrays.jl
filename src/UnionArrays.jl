module UnionArrays

include("abstract/abstract.jl")
include("impl/impl.jl")

Abstract.UnionVector(args...; kwargs...) = Impl.UnionVector(args...; kwargs...)

using .Abstract: UnionArray, UnionVector, UnionMatrix
export UnionArray, UnionVector, UnionMatrix

end # module
