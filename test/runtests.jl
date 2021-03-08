module TestUnionArrays
using Test

const TEST_CUDA = try
    import CUDA
    CUDA.has_cuda_gpu()
catch
    false
end
const TEST_GPU = TEST_CUDA

TEST_CUDA && CUDA.allowscalar(false)

find_test(subdir = "") = sort([
    joinpath(subdir, file) for file in readdir(joinpath(@__DIR__, subdir)) if
    match(r"^test_.*\.jl$", file) !== nothing
])

@testset "$file" for file in find_test()
    TEST_GPU || include(file)
end

@testset "$file" for file in find_test("cuda")
    TEST_CUDA && include(file)
end

end  # module
