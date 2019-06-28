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

Base.size(A::UnionVector) = size(A.data)

function UnionVector(ETS::Tuple, items::AbstractVector)
    # TODO: relax this
    maxsize = max(sizeof.(ETS)...)
    @assert maxsize == max(sizeof.(ETS)...)
    elsize = maxsize

    typeid = zeros(UInt8, length(items))
    BT = Tuple{ntuple(_ -> UInt8, elsize)...}
    data = Vector{BT}(undef, length(items))
    for (i, d) in enumerate(items)
	for (id, T) in enumerate(ETS)
	    if d isa T
		typeid[i] = id
		reinterpret(T, data)[i] = d
		@goto found
	    end
	end
	error("$i-th value in `items` is of type $(typeof(d)); not found in:\n",
	      ETS)

	@label found
    end
    return UnionVector(Tuple{ETS...}, data, typeid)
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
    reinterpret(typeat(A, i), A.data)[i]
