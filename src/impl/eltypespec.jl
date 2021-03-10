"""
    unionof(T₁, T₂, ...)

Similar to `Union{T₁, T₂, ...}` but the order is preserved. This object can
be passed to `UnionArray` to specify the element type.
"""
function UnionArrays.unionof(types::Type...)
    vals = foldlargs((), types...) do vals, T
        (vals..., Val{T}())
    end
    return verify(UnionOf(vals))
end

const NTypes{N} = NTuple{N, Val}

struct UnionOf{T<:NTypes}
    types::T
end

const ElTypeSpec = Union{Type, NTypes, UnionOf}

astupletype(u::UnionOf) =
    foldrargs(u.types..., Tuple{}) do v, T
        Base.tuple_type_cons(valueof(v), T)
    end

asunion(u::UnionOf) = asunion(u.types)

asunion(types::NTypes) =
    foldlargs(Union{}, types...) do T, v
        Union{T,valueof(v)}
    end

asntypes(types::NTypes) = types
asntypes(u::UnionOf) = u.types
@generated asntypes(::Type{T}) where {T} =
    QuoteNode(foldrunion((S, types) -> (Val(S), types...), T, ()))

function verify(u::UnionOf)
    if length(u.types) != union_ntypes(asunion(u))
        error("non-unique types are provided")
    end
    return u
end

function Base.show(io::IO, u::UnionOf)
    @nospecialize u
    print(io, UnionArrays.unionof)
    print(io, '(')
    isfirst = true
    for v in u.types
        if !isfirst
            print(io, ", ")
        end
        isfirst = false
        print(io, valueof(v))
    end
    print(io, ')')
end
