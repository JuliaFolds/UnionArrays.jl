struct UnionVector{
    T,
    ETS <: NTypes,
    TD <: AbstractVector,
    TM <: AbstractVector{UInt8},
    TV <: Tuple
} <: Abstract.UnionVector{T}

    types::ETS
    data::TD
    typeid::TM
    views::TV

    function UnionVector(
        types::ETS,
        data::TD,
        typeid::TM,
        views::TV,
    ) where {
        ETS <: NTypes,
        TD <: AbstractVector,
        TM <: AbstractVector{UInt8},
        TV <: Tuple,
    }
        A = new{asunion(types),ETS,TD,TM,TV}(types, data, typeid, views)
        @static if VERSION >= v"1.6-"
            return verify(A)
        else
            return A
        end
    end
end

if VERSION >= v"1.6-"
    Adapt.adapt_structure(to, A::UnionVector) =
        UnionVector(A.types, Adapt.adapt(to, A.data), Adapt.adapt(to, A.typeid))
else
    Adapt.adapt_structure(to, A::UnionVector) = UnionVector(
        A.types,
        Adapt.adapt(to, A.data),
        Adapt.adapt(to, A.typeid),
        Adapt.adapt(to, A.views),
    )
end

executor_type(A::UnionVector) = executor_type(A.data)

function UnionVector(ETS::ElTypeSpec, data::AbstractVector, typeid::AbstractVector{UInt8})
    types = asntypes(ETS)
    views = foldlargs((), types...) do views, v
        return (views..., reinterpret(ofsamesize(eltype(data), valueof(v)), data))
    end
    return UnionVector(types, data, typeid, views)
end

UnionArrays.buffereltypefor(ETS::ElTypeSpec) =
    foldlargs(Nothing, asntypes(ETS)...) do S, x
        Base.@_inline_meta
        T = valueof(x)
        if sizeof_aligned(S) < sizeof_aligned(T)
            T
        else
            S
        end
    end

UnionArrays.buffereltypeof(A::UnionVector) = eltype(A.data)

function UnionArrays.eltypebyid(A::UnionVector, ::Val{id}) where {id}
    id > length(A.types) && return Union{}
    id < 1 && return Union{}
    return valueof(A.types[id])
end

Base.size(A::UnionVector) = size(A.data)

UnionVector(undef::UndefInitializer, ETS::ElTypeSpec, n::Integer) =
    UnionVector(undef, Vector, ETS, n)

UnionVector(
    undef::UndefInitializer,
    VectorType::Type{<:AbstractVector},
    ETS::ElTypeSpec,
    n::Integer,
) = UnionVector(undef, VectorType, VectorType{UInt8}, ETS, n)

function UnionVector(
    ::UndefInitializer,
    DataVectorType::Type{<:AbstractVector},
    TypeTagVectorType::Type{<:AbstractVector{UInt8}},
    ETS::ElTypeSpec,
    n::Integer,
)
    typeid = TypeTagVectorType(undef, n)
    fill!(typeid, 0)
    BT = buffereltypefor(ETS)
    data = DataVectorType{BT}(undef, n)
    return UnionVector(ETS, data, typeid)
end

function UnionVector(ETS::ElTypeSpec, items::AbstractVector)
    A = UnionVector(undef, ETS, length(items))
    for i in axes(A, 1)
        # TODO: find the best way to support arrays with offset
        @inbounds A[i] = items[i - firstindex(A) + firstindex(items)]
    end
    return A
end

function UnionVector(data::AbstractVector)
    ETS = foldl(data, init=Union{}) do ETS, x
        Union{ETS,typeof(x)}
    end
    return UnionVector(ETS, data)
end

struct InvalidUnionVector{T<:UnionVector} <: Exception
    A::T
end

function Base.showerror(io::IO, err::InvalidUnionVector)
    A = err.A
    unmatches = filter!(collect(Pair{Int,Any}, pairs(A.views))) do (_, xs)
        UInt(pointer(A.data)) != UInt(pointer(xs))
    end
    print(io, "invalid UnionVector: ")
    println(io, length(unmatches), " incompatible views")
    println(io, "data pointer: ", pointer(A.data))
    for (i, xs) in unmatches
        println(io, i, "-th view pointer: ", pointer(xs))
    end
end

function verify(A::UnionVector)
    foldlargs(true, A.views...) do ok, xs
        Base.@_inline_meta
        ok && UInt(pointer(A.data)) == UInt(pointer(xs))
    end || throw(InvalidUnionVector(A))
    return A
end

Base.@propagate_inbounds typeat(A::UnionVector{<:Any, ETS}, i) where ETS =
    fieldtype(ETS, Int(A.typeid[i]))

struct TypeIDLookupFailed <: Exception
    id::Int
end

Base.showerror(io::IO, err::TypeIDLookupFailed) =
    print(io, "lookup of type id $(err.id) failed")

# Using CPS for begging the compiler to union split things:
@inline function view_by_id(f::F, A::UnionVector, id::Integer) where {F}
    @noinline unreachable() = throw(TypeIDLookupFailed(id))
    return terminating_foldlargs(unreachable, 1, A.views...) do j, xs
        Base.@_inline_meta
        if j == id
            Reduced(f(xs))
        else
            j + 1
        end
    end
end

@inline function Base.getindex(A::UnionVector, i::Int)
    @boundscheck checkbounds(A, i)
    return view_by_id(A, A.typeid[i]) do xs
        Base.@_inline_meta
        unpad(@inbounds xs[i])
    end
end

struct ElTypeLookupFailed{T} <: Exception end
Base.showerror(io::IO, ::ElTypeLookupFailed{T}) where {T} =
    print(io, "unsupported element type (type conversion not implemented yet); $T")

# Using CPS for begging the compiler to union split things:
# TODO: handle conversion
@inline function view_and_id(f::F, A::UnionVector, ::Type{T}) where {F,T}
    @noinline unreachable() = throw(ElTypeLookupFailed{T}())
    V = Val(T)
    return terminating_foldlargs(unreachable, 1, A.views...) do id, xs
        Base.@_inline_meta
        if paddedtype(eltype(xs)) === valueof(V)
            Reduced(f(xs, id))
        else
            id + 1
        end
    end
end

# Base.checkbounds(::Type{Bool}, A::UnionVector, i) =
#     checkbounds(Bool, A.data, i) && checkbounds(Bool, A.typeid, i)

@inline function Base.setindex!(A::UnionVector, v, i::Int)
    @boundscheck checkbounds(A, i)
    typeid = A.typeid
    view_and_id(A, typeof(v)) do xs, id
        Base.@_inline_meta
        @inbounds typeid[i] = id
        @inbounds xs[i] = v
        nothing
    end
end

function Base.fill!(A::UnionVector, x)
    v = convert(eltype(A), x)
    p = v  # TODO: handle padding
    view_and_id(A, typeof(v)) do xs, id
        fill!(xs, p)
        fill!(A.typeid, id)
        nothing
    end
    return A
end
