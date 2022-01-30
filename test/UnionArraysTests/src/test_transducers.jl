module TestTransducers

using Test
using Transducers
using UnionArrays

using ..Utils: compile_enabled

function test()
    xs = UnionVector(Any[1, 2.0])
    @test foldl(+, Map(x -> 2x), xs) == 6

    ys = eduction(Map(x -> 2x), xs)
    if compile_enabled()
        @test (@inferred foldl(+, ys, init=0.0)) == 6
    end
end

end  # module
