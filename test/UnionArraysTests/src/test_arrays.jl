module TestArrays

using UnionArrays
using Test

function test()
    A = reshape(UnionVector(Any[1, 2.0]), 1, :)
    @test A isa UnionArray
    @test A[1] === 1
    @test A[2] === 2.0
    @test A[1, 1] === 1
    @test A[1, 2] === 2.0
    @test (A[1, 1] = 3.0) isa Any
    @test A[1, 1] === 3.0
    @test (A[1] = 3.0) isa Any
    @test A[1] === 3.0
end

end  # module
