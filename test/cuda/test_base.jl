module TestBase

using CUDA
using Test
using UnionArrays

const ==′ = isequal

@testset "UnionVector" begin
    xs = UnionVector(undef, CuVector, (Float32, Missing), 3)
    fill!(xs, 1)
    CUDA.@allowscalar xs[2] = missing
    @test (CUDA.@allowscalar xs[1]) === 1.0f0
    @test (CUDA.@allowscalar xs[2]) === missing
    @test (CUDA.@allowscalar xs[3]) === 1.0f0
    @test collect(xs) ==′ [1.0f0, missing, 1.0f0]
end

@testset "UnionMatrix" begin
    A = UnionArray(undef, CuVector, (Float32, Missing), (3, 2))
    fill!(A, 1)
    CUDA.@allowscalar A[2, 2] = missing
    @test (CUDA.@allowscalar A[1, 1]) === 1.0f0
    @test (CUDA.@allowscalar A[2, 2]) === missing
    @test (CUDA.@allowscalar A[3, 2]) === 1.0f0
    @test collect(A) ==′ [
        1.0f0 1.0f0
        1.0f0 missing
        1.0f0 1.0f0
    ]
end

end  # module
