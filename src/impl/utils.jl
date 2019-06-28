TypeTuple{N} = NTuple{N, Type}

@inline foldlargs(op, x) = x
@inline foldlargs(op, x1, x2, xs...) =
    foldlargs(op,
              @return_if_reduced(op(x1, x2)),
              xs...)

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

asunion(T::Type{<:Tuple}) = foldltupletype((T, s) -> Union{T, s}, Union{}, T)
