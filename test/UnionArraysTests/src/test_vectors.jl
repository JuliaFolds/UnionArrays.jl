module TestVectors

using UnionArrays
using Test

function test_homogeneous_size()
    xs = UnionVector(Any[1, 2.0])
    @test xs[1] === 1
    @test xs[2] === 2.0
    @test (xs[1] = 3.0) isa Any
    @test xs[1] === 3.0
end

function test_heterogeneous_size()
    xs = UnionVector(Any[UInt8(1), 2.0, (a=1, b=2)])
    @test xs[1] === UInt8(1)
    @test xs[2] === 2.0
    @test xs[3] === (a=1, b=2)
    @test (xs[1] = 3.0) isa Any
    @test xs[1] === 3.0
end

end  # module
