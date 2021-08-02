module UnionArraysCUDATests

import CUDA

function include_tests(m = @__MODULE__, dir = @__DIR__)
    for file in readdir(dir)
        if match(r"^test_.*\.jl$", file) !== nothing
            Base.include(m, joinpath(dir, file))
        end
    end
end

include_tests()

function before_test_module()
    CUDA.allowscalar(false)

    if lowercase(get(ENV, "CI", "false")) == "true"
        CUDA.versioninfo()
        println()
    end
end

end  # module UnionArraysCUDATests
