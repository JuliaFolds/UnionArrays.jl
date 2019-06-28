module TestTransducers

include("preamble.jl")
using Transducers

@testset begin
    xs = UnionVector(Any[1, 2.0])
    @test foldl(+, Map(x -> 2x), xs) == 6

    ys = eduction(Map(x -> 2x), xs)
    if COMPILE_ENABLED
        @test (@inferred foldl(+, ys, init=0.0)) == 6
    end
end

end  # module
