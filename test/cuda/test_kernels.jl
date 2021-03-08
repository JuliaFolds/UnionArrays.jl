module TestKernels

using CUDA
using Test
using UnionArrays

function kernel_test_shmem!(ys)
    iglobal = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    T = Union{Nothing,Float32}
    S = UnionArrays.buffereltypefor(T)
    data = @cuDynamicSharedMem(S, (blockDim().x,))
    typeids = @cuDynamicSharedMem(UInt8, (blockDim().x,), sizeof(data))
    xs = UnionVector(T, data, typeids)
    if isodd(threadIdx().x)
        xs[threadIdx().x] = Float32(iglobal)
    else
        xs[threadIdx().x] = nothing
    end
    sync_threads()
    i = mod1(threadIdx().x + 1, blockDim().x)
    x = xs[i]
    sync_threads()
    xs[threadIdx().x] = x
    sync_threads()
    ys[iglobal] = xs[i]
    return
end

function host_test_shmem()
    threads = 8
    blocks = 3
    ys = UnionVector(undef, CuVector, (Float32, Nothing), threads * blocks)
    fill!(ys, 0)
    shmem = (sizeof(UnionArrays.buffereltypeof(ys)) + sizeof(UInt8)) * threads
    CUDA.@sync @cuda threads=threads blocks=blocks shmem=shmem kernel_test_shmem!(ys)
    return ys
end

@testset "shmem" begin
    xs = collect(Union{Nothing,Float32}, 1:8 * 3)
    xs[2:2:end] .= nothing
    for block in Iterators.partition(eachindex(xs), 8)
        xs[block] = circshift(xs[block], -2)
    end
    @test collect(host_test_shmem()) == xs
end

end  # module
