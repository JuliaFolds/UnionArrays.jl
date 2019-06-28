module TestVectors

include("preamble.jl")

@testset "homogeneous size" begin
    xs = UnionVector(Any[1, 2.0])
    @test xs[1] === 1
    @test xs[2] === 2.0
    @test (xs[1] = 3.0) isa Any
    @test xs[1] === 3.0
end

@testset "heterogeneous size" begin
    xs = UnionVector(Any[UInt8(1), 2.0, (a=1, b=2)])
    @test xs[1] === UInt8(1)
    @test xs[2] === 2.0
    @test xs[3] === (a=1, b=2)
    @test (xs[1] = 3.0) isa Any
    @test xs[1] === 3.0
end

end  # module
