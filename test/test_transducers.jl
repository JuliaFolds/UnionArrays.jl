module TestTransducers

include("preamble.jl")
using Transducers

@testset begin
    xs = UnionVector(Any[1, 2.0])
    @test foldl(+, Map(x -> 2x), xs) == 6
end

end  # module
