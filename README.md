# UnionArrays: storage-agnostic array type with `Union` elements

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliafolds.github.io/UnionArrays.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliafolds.github.io/UnionArrays.jl/dev)
[![GitHub Actions](https://github.com/JuliaFolds/UnionArrays.jl/workflows/Run%20tests/badge.svg)](https://github.com/JuliaFolds/UnionArrays.jl/actions?query=workflow%3ARun+tests)
[![Codecov](https://codecov.io/gh/JuliaFolds/UnionArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaFolds/UnionArrays.jl)
[![GitHub last commit](https://img.shields.io/github/last-commit/JuliaFolds/UnionArrays.jl.svg?style=social&logo=github)](https://github.com/JuliaFolds/UnionArrays.jl)

UnionArrays.jl provides an array type with `Union` element types that is
generic over the data storage type.

```julia
julia> using UnionArrays

julia> xs = UnionVector(undef, Vector, Union{Float32,Tuple{},UInt8}, 3);

julia> fill!(xs, ());

julia> xs[1]
()

julia> xs[2] = 1.0f0;

julia> xs[3] = UInt8(2);

julia> collect(xs)
3-element Vector{Union{Tuple{}, Float32, UInt8}}:
     ()
    1.0f0
 0x02
```

For example, it can be used for bringing `Union` element types to GPU:

```julia
julia> using CUDA

julia> xs = UnionVector(undef, CuVector, Union{Float32,Nothing}, 3);

julia> fill!(xs, nothing);
```

Packages like [Transducers.jl](https://github.com/JuliaFolds/Transducers.jl)
and [Folds.jl](https://github.com/JuliaFolds/Folds.jl) support computations
with `UnionArray`s on GPU:

```julia
julia> using Folds, FoldsCUDA

julia> Folds.all(==(nothing), xs)
true

julia> CUDA.@allowscalar begin
           xs[2] = 1.0f0
           xs[3] = 2.0f0
       end;

julia> Folds.sum(x -> x === nothing ? 0.0f0 : x, xs; init = 0.0f0)
3.0f0
```
