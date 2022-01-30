module TestPadded

using UnionArrays
using UnionArrays.Impl: ofsamesize, unpad, Padded
using Test

function test_ofsamesize()
    @testset "bigger = $bigger" for (bigger, value) in [
        (Float64, UInt8(0)),
        (NTuple{7, UInt8}, UInt8(0)),
    ]
        @testset for smaller in [value, typeof(value)]
            padded = ofsamesize(bigger, smaller)
            @test sizeof(padded) == sizeof(bigger)
            @test unpad(padded) === smaller
        end
    end
end

function test_convert()
    xs = ofsamesize.(Float64, UInt8.(1:10)) :: Vector
    @test eltype(xs) <: Padded
    @test unpad(xs[1]) === UInt8(1)
    xs[1] = UInt8(2)
    @test unpad(xs[1]) === UInt8(2)
    xs[1] = ofsamesize(Float64, UInt8(3))
    @test unpad(xs[1]) === UInt8(3)
end

end  # module
