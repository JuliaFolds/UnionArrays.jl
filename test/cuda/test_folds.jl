module TestFolds

using CUDA
using Folds
using FoldsCUDA
using Test
using UnionArrays

@testset "UnionVector" begin
    xs = UnionVector(undef, CuVector, (Float32, Missing), 3)
    fill!(xs, 1)
    CUDA.@allowscalar xs[2] = missing
    @test (CUDA.@allowscalar xs[1]) === 1.0f0
    @test (CUDA.@allowscalar xs[2]) === missing
    @test (CUDA.@allowscalar xs[3]) === 1.0f0
    @test Folds.sum(x -> x isa Missing ? 0.0f0 : x, xs, CUDAEx()) == 2
end

@testset "UnionMatrix" begin
    A = UnionArray(undef, CuVector, (Float32, Missing), (3, 2))
    fill!(A, 1)
    CUDA.@allowscalar A[2, 2] = missing
    @test (CUDA.@allowscalar A[1, 1]) === 1.0f0
    @test (CUDA.@allowscalar A[2, 2]) === missing
    @test (CUDA.@allowscalar A[3, 2]) === 1.0f0
    @test Folds.sum(x -> x isa Missing ? 0.0f0 : x, A, CUDAEx()) == 5
end

end  # module
