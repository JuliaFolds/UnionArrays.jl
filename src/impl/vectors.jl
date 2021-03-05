struct UnionVector{
    T,
    ETS,
    TD <: AbstractVector,
    TM <: AbstractVector{UInt8},
    TV <: Tuple
} <: Abstract.UnionVector{T}

    data::TD
    typeid::TM
    views::TV

    function UnionVector(
        ::Type{ETS},
        data::TD,
        typeid::TM,
        views::TV,
    ) where {
        ETS <: Tuple,
        TD <: AbstractVector,
        TM <: AbstractVector{UInt8},
        TV <: Tuple,
    }
        return new{asunion(ETS), ETS, TD, TM, TV}(data, typeid, views)
    end
end

Adapt.adapt_structure(to, A::UnionVector{<:Any,ETS}) where {ETS} = UnionVector(
    ETS,
    Adapt.adapt(to, A.data),
    Adapt.adapt(to, A.typeid),
    Adapt.adapt(to, A.views),
)

function UnionVector(ETS::Type, data::AbstractVector, typeid::AbstractVector{UInt8})
    views = foldltupletype((), ETS) do views, ET
        return (views..., reinterpret(ofsamesize(eltype(data), ET), data))
    end
    return UnionVector(ETS, data, typeid, views)
end

const ElTypeSpec = Union{Type{<:Tuple}, TypeTuple}
aseltypetuple(::Type{ETS}) where {ETS <: Tuple} = ETS
aseltypetuple(ETS::TypeTuple) = Tuple{ETS...}

eltypetuple(A::UnionVector{<:Any, ETS}) where ETS = ETS

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
    elsize = max(map(sizeof, astupleoftypes(ETS))...)
    typeid = TypeTagVectorType(undef, n)
    fill!(typeid, 0)
    BT = NTuple{elsize,UInt8}
    data = DataVectorType{BT}(undef, n)
    return UnionVector(aseltypetuple(ETS), data, typeid)
end

function UnionVector(ETS::Tuple, items::AbstractVector)
    A = UnionVector(undef, ETS, length(items))
    for i in axes(A, 1)
        # TODO: find the best way to support arrays with offset
        @inbounds A[i] = items[i - firstindex(A) + firstindex(items)]
    end
    return A
end

function UnionVector(data::AbstractVector)
    ETS = foldl(data, init=()) do ETS, d
	T = typeof(d)
	if T ∉ ETS
	    ETS = (ETS..., T)
	end
	return ETS
    end
    return UnionVector(ETS, data)
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

# TODO: handle conversion
view_and_id(A::UnionVector, T::Type) =
    foldlargs(1, A.views...) do id, xs
        if paddedtype(eltype(xs)) === T
            reduced((xs, id))
        else
            id + 1
        end
    end |> ifunreduced() do _
        error("unsupported element type (type conversion not implemented yet)")
    end

# Base.checkbounds(::Type{Bool}, A::UnionVector, i) =
#     checkbounds(Bool, A.data, i) && checkbounds(Bool, A.typeid, i)

Base.@propagate_inbounds function Base.setindex!(A::UnionVector, v, i::Int)
    xs, id = view_and_id(A, typeof(v))
    A.typeid[i] = id
    xs[i] = v
    return
end

function Base.fill!(A::UnionVector, x)
    v = convert(eltype(A), x)
    p = v  # TODO: handle padding
    xs, id = view_and_id(A, typeof(v))
    fill!(xs, p)
    fill!(A.typeid, id)
    return A
end
