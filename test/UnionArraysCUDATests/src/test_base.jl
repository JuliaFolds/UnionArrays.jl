module TestBase

using CUDA
using Test
using UnionArrays
using UnionArrays: unionof

const ==′ = isequal

function test_unionvector()
    xs = UnionVector(undef, CuVector, unionof(Float32, Missing), 3)
    fill!(xs, 1)
    CUDA.@allowscalar xs[2] = missing
    @test (CUDA.@allowscalar xs[1]) === 1.0f0
    @test (CUDA.@allowscalar xs[2]) === missing
    @test (CUDA.@allowscalar xs[3]) === 1.0f0
    @test collect(xs) ==′ [1.0f0, missing, 1.0f0]
end

function test_unionmatrix()
    A = UnionArray(undef, CuVector, unionof(Float32, Missing), (3, 2))
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
