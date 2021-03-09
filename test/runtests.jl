module TestUnionArrays
using Test

if VERSION ≥ v"1.6-"
    try
        pkgid = Base.PkgId(Base.UUID("052768ef-5323-5732-b1bb-66c8b64840ba"), "CUDA")
        Base.require(pkgid)
    catch
        @info "Failed to import CUDA. Trying again with `@stdlib`..."
        push!(LOAD_PATH, "@stdlib")
    end
end

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
    if VERSION < v"1.6-"
        basename(file) == "test_kernels.jl" && continue
        basename(file) == "test_doctest.jl" && continue
    end
    TEST_CUDA && include(file)
end

end  # module
