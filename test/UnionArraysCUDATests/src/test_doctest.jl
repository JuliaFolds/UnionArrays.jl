module TestDoctest

using UnionArrays
using Documenter: doctest
using Test

function test()
    doctest(UnionArrays)
end

should_test_module() = VERSION >= v"1.6-"

end  # module
