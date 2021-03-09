module TestFoldsCUDATests
const HAS_FOLDSCUDATESTS = try
    using FoldsCUDATests
    true
catch err
    @info "Failed to import `FoldsCUDATests`" exception = (err, catch_backtrace())
    false
end
if HAS_FOLDSCUDATESTS
    FoldsCUDATests.runtests_unionarrays()
end
end  # module
