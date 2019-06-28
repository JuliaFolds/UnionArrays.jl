@inline function Transducers.__foldl__(rf, val, A::UnionVector)
    @assert size(A.data) == size(A.typeid)
    for i in axes(A, 1)
        val = @return_if_reduced let i = i, val = val
            foldlargs(1, A.views...) do id, v
                Base.@_inline_meta
                if @inbounds A.typeid[i] == id
                    # input = @inbounds v[i]
                    input = GC.@preserve v unsafe_load(pointer(v, i))
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
