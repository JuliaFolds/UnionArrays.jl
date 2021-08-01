using TestFunctionRunner

let env_test_cuda = lowercase(get(ENV, "UNIONARRAYS_JL_TEST_CUDA", "auto")),
    test_cuda = if env_test_cuda == "auto"
        try
            import CUDA
            true
        catch
            false
        end
    else
        env_test_cuda == "true"
    end

    if test_cuda
        TestFunctionRunner.@run(packages = ["UnionArraysCUDATests"])

        try
            using FoldsCUDATests
            true
        catch err
            @info "Failed to import `FoldsCUDATests`" exception = (err, catch_backtrace())
            false
        end && begin
            FoldsCUDATests.runtests_unionarrays()
        end
    else
        TestFunctionRunner.@run(packages = ["UnionArraysTests"])
    end
end
