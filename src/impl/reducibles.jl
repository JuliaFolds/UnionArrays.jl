function Transducers.__foldl__(rf, val, A::UnionVector)
    @assert size(A.data) == size(A.typeid)
    for i in axes(A, 1)
        val = @return_if_reduced let i = i, val = val
            foldltupletype(1, eltypetuple(A)) do id, ET
                if @inbounds A.typeid[i] == id
                    input = @inbounds _getindex(A, i, ET)
                    Reduced(next(rf, val, input))
                else
                    id + 1
                end
            end :: Reduced |> unreduced
        end
    end
    return complete(rf, val)
end
# NOTE: Using `Reduced` and not `reduced` to exit `foldltupletype` but
# not `__foldl__` unless `next` returns a `Reduced` as well.  In this
# case (i.e., `next` returned a `Reduced`), the returned value of
# `foldltupletype` is doubly wrapped in `Reduced`.
