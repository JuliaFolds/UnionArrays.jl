module TestVectors

include("preamble.jl")

@testset begin
    xs = UnionVector(Any[1, 2.0])
    @test xs[1] === 1
    @test xs[2] === 2.0
    @test (xs[1] = 3.0) isa Any
    @test xs[1] === 3.0
end

end  # module
