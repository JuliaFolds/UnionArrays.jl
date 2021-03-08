using Adapt: adapt

default_collect(A::AbstractArray{T,N}) where {T,N} =
    invoke(collect, Tuple{AbstractArray{T,N}}, A)

Base.collect(A::UnionArray) = default_collect(adapt(Array, A))
