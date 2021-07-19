valueof(::Val{x}) where {x} = x

# Not exactly `Base.aligned_sizeof`
Base.@pure function sizeof_aligned(T::Type)
    if isbitstype(T)
        al = Base.datatype_alignment(T)
        return (Core.sizeof(T) + al - 1) & -al
    else
        return nothing
    end
end

TypeTuple{N} = NTuple{N, Type}

astupleoftypes(x::TypeTuple) = x
astupleoftypes(::Type{T}) where {T <: Tuple} = Tuple(T.parameters)

@inline foldlargs(op, x) = x
@inline foldlargs(op, x1, x2, xs...) =
    foldlargs(op,
              @return_if_reduced(op(x1, x2)),
              xs...)

@inline foldrargs(op, x) = x
@inline foldrargs(op, x1, x2, xs...) = op(x1, foldrargs(op, x2, xs...))

@inline foldltupletype(op, T, ::Type{<:Tuple{}}) = T
@inline foldltupletype(op, T, ::Type{S}) where {S <: Tuple} =
    foldltupletype(op,
                   @return_if_reduced(op(T, Base.tuple_type_head(S))),
		   Base.tuple_type_tail(S))

@inline foldltupletype(op, ::Type{T}, ::Type{<:Tuple{}}) where T = T
@inline foldltupletype(op, ::Type{T}, ::Type{S}) where {T, S <: Tuple} =
    foldltupletype(op,
                   @return_if_reduced(op(T, Base.tuple_type_head(S))),
          Base.tuple_type_tail(S))

@inline foldrunion(op, ::Type{T}, init) where {T} =
    if T isa Union
        acc = @return_if_reduced foldrunion(op, T.b, init)
        foldrunion(op, T.a, acc)
    else
        op(T, init)
    end

uniontotuple(::Type{T}) where {T} = foldrunion(Base.tuple_type_cons, T, Tuple{})

asunion(T::Type{<:Tuple}) = foldltupletype((T, s) -> Union{T, s}, Union{}, T)

union_ntypes(::Type{T}) where {T} = foldrunion((_, n) -> n + 1, T, 0)
tuple_ntypes(::Type{T}) where {T} = foldltupletype((n, _) -> n + 1, 0, T)

terminating_foldlargs(op, fallback) = fallback()
@inline function terminating_foldlargs(op, fallback::F, x1, x2, xs...) where {F}
    acc = op(x1, x2)
    acc isa Reduced && return unreduced(acc)
    return terminating_foldlargs(op, fallback, acc, xs...)
end

# Helping inference for CUDA.jl:
@inline function terminating_foldlargs(op, fallback, x1, x2)
    acc = op(x1, x2)
    acc isa Reduced && return unreduced(acc)
    return fallback()
end

@inline function terminating_foldlargs(op, fallback, x1, x2, x3)
    acc = op(x1, x2)
    acc isa Reduced && return unreduced(acc)
    acc = op(acc, x3)
    acc isa Reduced && return unreduced(acc)
    return fallback()
end


struct Padded{T, N}
    value::T
    pad::NTuple{N, UInt8}
end

Padded{T, N}(value::T) where {T, N} = Padded(value, zeropad(Val{N}()))
zeropad(N) = ntuple(_ -> UInt8(0), N)
addpadding(N::Integer, ::Type{T}) where T = Padded{T, N}
addpadding(N::Integer, value::T) where T = Padded{T, N}(value)

Base.convert(::Type{P}, x::T) where {T, P <: Padded{T}} = P(x)

unpad(x) = x
unpad(x::Padded) = x.value
unpad(::Type{<:Padded{T}}) where T = T

paddedtype(::T) where T = paddedtype(T)
paddedtype(::Type{<:Padded{T}}) where T = T
paddedtype(::Type{T}) where T = T

# not sure relying on `sizeof` is safe; so:
sizeoftype(::Type{T}) where T = sizeof(T)
sizeoftype(::T) where T = sizeof(T)

ofsamesize(bigger::Type, smaller) =
    if sizeof(bigger) < sizeoftype(smaller)
        error("Target type is not big enough")
    elseif sizeof(bigger) == sizeoftype(smaller)
        smaller
    else
        addpadding(sizeof(bigger) - sizeoftype(smaller), smaller)
    end
