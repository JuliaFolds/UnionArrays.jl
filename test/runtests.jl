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
        if lowercase(get(ENV, "CI", "false")) == "true"
            import CUDA
            CUDA.versioninfo()
            println()
        end

        TestFunctionRunner.@run(packages = ["UnionArraysCUDATests"])

        using FoldsCUDATests
        FoldsCUDATests.runtests_unionarrays()
    else
        TestFunctionRunner.@run(packages = ["UnionArraysTests"])
    end
end
