module TestPadded

include("preamble.jl")
using UnionArrays.Impl: ofsamesize, unpad, Padded

@testset "ofsamesize" begin
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

@testset "convert" begin
    xs = ofsamesize.(Float64, UInt8.(1:10)) :: Vector
    @test eltype(xs) <: Padded
    @test unpad(xs[1]) === UInt8(1)
    xs[1] = UInt8(2)
    @test unpad(xs[1]) === UInt8(2)
    xs[1] = ofsamesize(Float64, UInt8(3))
    @test unpad(xs[1]) === UInt8(3)
end

end  # module
