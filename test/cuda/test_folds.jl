module TestFolds

using CUDA
using Folds
using FoldsCUDA
using Test
using UnionArrays

@testset begin
    xs = UnionVector(undef, CuVector, (Float32, Missing), 3)
    fill!(xs, 1)
    CUDA.@allowscalar xs[2] = missing
    @test (CUDA.@allowscalar xs[1]) === 1.0f0
    @test (CUDA.@allowscalar xs[2]) === missing
    @test (CUDA.@allowscalar xs[3]) === 1.0f0
    @test Folds.sum(x -> x isa Missing ? 0.0f0 : x, xs, CUDAEx()) == 2
end

end  # module
