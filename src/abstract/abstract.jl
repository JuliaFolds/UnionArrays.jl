module Abstract

"""
    UnionArray{T, N}
    UnionVector{T}
    UnionMatrix{T}

`UnionArray` stores heterogeneous elements without indirections (which
would happen in `Array{Any}`).

# Examples
```jldoctest
julia> using UnionArrays

julia> xs = UnionVector(Any[UInt8(1), 2.0, (a=1, b=2)]);

julia> xs[1]
0x01

julia> xs[2]
2.0

julia> xs[3]
(a = 1, b = 2)

julia> xs[1] = (a=3, b=4);

julia> xs[1]
(a = 3, b = 4)

julia> M = reshape(xs, (1, :)) :: UnionMatrix;

julia> M[1, 1]
(a = 3, b = 4)
```
"""
abstract type UnionArray{T, N} <: AbstractArray{T, N} end

const UnionVector{T} = UnionArray{T, 1}
const UnionMatrix{T} = UnionArray{T, 2}

end  # module
