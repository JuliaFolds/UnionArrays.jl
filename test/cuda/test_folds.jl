module TestFolds

using CUDA
using Folds
using FoldsCUDA
using Test
using UnionArrays

const ==′ = isequal

@testset "UnionVector" begin
    xs = UnionVector(undef, CuVector, (Float32, Missing), 3)
    fill!(xs, 1)
    CUDA.@allowscalar xs[2] = missing
    @test collect(xs) ==′ [1.0f0, missing, 1.0f0]
    @test Folds.sum(x -> x isa Missing ? 0.0f0 : x, xs, CUDAEx()) == 2

    @testset "setindex!" begin
        ys = range(1.0f0, 3.0f0, length = 3)
        Folds.map!(identity, xs, ys)
        @test collect(xs) == 1:3

        Folds.map!(==(missing), xs, ys)
        @test collect(xs) ==′ [missing, missing, missing]
    end
end

@testset "UnionMatrix" begin
    A = UnionArray(undef, CuVector, (Float32, Missing), (3, 2))
    fill!(A, 1)
    CUDA.@allowscalar A[2, 2] = missing
    @test (CUDA.@allowscalar A[1, 1]) === 1.0f0
    @test (CUDA.@allowscalar A[2, 2]) === missing
    @test (CUDA.@allowscalar A[3, 2]) === 1.0f0
    @test Folds.sum(x -> x isa Missing ? 0.0f0 : x, A, CUDAEx()) == 5

    @testset "setindex!" begin
        B = reshape(range(1.0f0, 6.0f0, length = 6), 3, 2)
        Folds.map!(identity, A, B)
        @test collect(A) == B

        Folds.map!(==(missing), A, B)
        @test collect(A) ==′ fill(missing, 3, 2)
    end
end

end  # module
