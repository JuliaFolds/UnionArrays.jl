struct UnionArray{T, N, P} <: Abstract.UnionArray{T, N}
    parent::P

    function UnionArray(parent::P) where {T, N, P <: AbstractArray{T, N}}
        # Make sure that `A.parent` is not a UnionArray/Vector
        P <: UnionArrayImpls && throw(MethodError(UnionArray, (parent,)))
        return new{T, N, P}(parent)
    end
end

const UnionArrayImpls = Union{UnionVector, UnionArray}

function Adapt.adapt_structure(to, A::UnionArray)
    B = Adapt.adapt(to, parent(A))
    if B isa UnionArray
        # `Adapt.adapt` might just call `reshape`, which then wraps the array
        # to `UnionArray`. In this case, there is no need to re-wrap it:
        return B
    else
        # Maybe just throw?
        return UnionArray(B)
    end
end

# A very minimal dummy array implementation just for implementing `default_reshape`:
struct DummyArray{N} <: AbstractArray{Any,N}
    dims::NTuple{N,Int}
end
Base.size(A::DummyArray) = A.dims

function default_reshape(A::UnionVector, dims::T) where {T}
    dummy = reshape(DummyArray(size(A)), dims)
    return @set dummy.parent = A
end

ua_reshape(A::UnionVector, dims) = UnionArray(default_reshape(A, dims))
ua_reshape(A::UnionArray, dims) = UnionArray(reshape(A.parent, dims))
ua_reshape(A::UnionVector, ::Tuple{Colon}) = A
function ua_reshape(A::UnionArray, ::Tuple{Colon})
    v = reshape(A.parent, :)
    if v isa UnionVector
        return v
    else
        return UnionArray(v)
    end
end

Base.reshape(A::UnionArrayImpls, dims::Dims) =
    ua_reshape(A, dims) :: UnionArrayImpls
Base.reshape(A::UnionArrayImpls, dims::Tuple{Vararg{Union{Int,Colon}}}) =
    ua_reshape(A, dims) :: UnionArrayImpls

Base.parent(A::UnionArray) = A.parent
Base.size(A::UnionArray) = size(A.parent)
Base.getindex(A::UnionArray, I...) = A.parent[I...]
Base.setindex!(A::UnionArray, v, I...) = setindex!(A.parent, v, I...)

# Base.showarg(io::IO, A::UnionArray, toplevel) =
#     Base.showarg(io, A.parent, toplevel)

Abstract.UnionArray(
    undef::UndefInitializer,
    VectorType::Type{<:AbstractVector},
    ETS::ElTypeSpec,
    dims::Union{Integer,Tuple{Vararg{Integer}}},
) = Abstract.UnionArray(undef, VectorType, VectorType{UInt8}, ETS, dims)

Abstract.UnionArray(
    undef::UndefInitializer,
    DataVectorType::Type{<:AbstractVector},
    TypeTagVectorType::Type{<:AbstractVector{UInt8}},
    ETS::ElTypeSpec,
    n::Union{Integer,Tuple{Integer}},
) = UnionVector(undef, DataVectorType, TypeTagVectorType, ETS, first(n))

Abstract.UnionArray(
    undef::UndefInitializer,
    DataVectorType::Type{<:AbstractVector},
    TypeTagVectorType::Type{<:AbstractVector{UInt8}},
    ETS::ElTypeSpec,
    dims::Tuple{Integer,Integer,Vararg{Integer}},
) = reshape(UnionVector(undef, DataVectorType, TypeTagVectorType, ETS, prod(dims)), dims)

function Base.fill!(A::UnionArray, x)
    fill!(parent(parent(A)), x)
    return A
end
