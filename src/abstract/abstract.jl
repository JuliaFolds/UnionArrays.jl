module Abstract

abstract type UnionArray{T, N} <: AbstractArray{T, N} end

const UnionVector{T} = UnionArray{T, 1}
const UnionMatrix{T} = UnionArray{T, 2}

end  # module
