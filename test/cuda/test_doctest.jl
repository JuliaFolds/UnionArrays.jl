module TestDoctest

using UnionArrays
using Documenter: doctest
using Test

@testset begin
    doctest(UnionArrays)
end

end  # module
