foldltupletype(op, T, ::Type{<:Tuple{}}) = T
foldltupletype(op, T, ::Type{S}) where {S <: Tuple} =
    foldltupletype(op,
                   op(T, Base.tuple_type_head(S)),
		   Base.tuple_type_tail(S))

asunion(T::Type{<:Tuple}) = foldltupletype((T, s) -> Union{T, s}, Union{}, T)
