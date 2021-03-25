module TestUnionArrays
using Test

env_test_cuda = lowercase(get(ENV, "UNIONARRAYS_JL_TEST_CUDA", "auto"))

const TEST_CUDA = if env_test_cuda == "true"
    import CUDA
    true
elseif env_test_cuda == "auto"
    try
        import CUDA
        CUDA.has_cuda_gpu()
    catch
        false
    end
else
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
    if VERSION < v"1.6-"
        basename(file) == "test_kernels.jl" && continue
        basename(file) == "test_doctest.jl" && continue
    end
    TEST_CUDA && include(file)
end

end  # module
