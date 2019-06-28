struct UnionVector{
    T,
    ETS,
    TD <: AbstractVector,
    TM <: Vector{UInt8},
} <: Abstract.UnionVector{T}
    data::TD
    typeid::TM

    function UnionVector(::Type{ETS}, data::TD, typeid::TM) where {
        ETS <: Tuple,
        TD <: AbstractVector,
        TM <: Vector{UInt8}
    }
        return new{asunion(ETS), ETS, TD, TM}(data, typeid)
    end
end

const ElTypeSpec = Union{Type{<:Tuple}, TypeTuple}
aseltypetuple(::Type{ETS}) where {ETS <: Tuple} = ETS
aseltypetuple(ETS::TypeTuple) = Tuple{ETS...}

eltypetuple(A::UnionVector{<:Any, ETS}) where ETS = ETS

Base.size(A::UnionVector) = size(A.data)

function UnionVector(::UndefInitializer, ETS::ElTypeSpec, n::Integer)
    # TODO: relax this
    maxsize = max(sizeof.(ETS)...)
    @assert maxsize == max(sizeof.(ETS)...)
    elsize = maxsize

    typeid = zeros(UInt8, n)
    BT = Tuple{ntuple(_ -> UInt8, elsize)...}
    data = Vector{BT}(undef, n)
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

Base.@propagate_inbounds Base.getindex(A::UnionVector, i::Int) =
    _getindex(A, i, typeat(A, i))

Base.@propagate_inbounds _getindex(A::UnionVector, i::Int, T::Type) =
    reinterpret(T, A.data)[i]

# TODO: handle conversion
typeandid(A::UnionVector, T::Type) =
    foldltupletype(1, eltypetuple(A)) do id, ET
        if ET === T
            reduced((ET, id))
        else
            id + 1
        end
    end |> ifunreduced() do _
        error("unsupported element type (type conversion not implemented yet)")
    end

# Base.checkbounds(::Type{Bool}, A::UnionVector, i) =
#     checkbounds(Bool, A.data, i) && checkbounds(Bool, A.typeid, i)

Base.@propagate_inbounds function Base.setindex!(A::UnionVector, v, i::Int)
    T, id = typeandid(A, typeof(v))
    A.typeid[i] = id
    reinterpret(T, A.data)[i] = v
    return
end
