module TestAqua

import Aqua
import UnionArrays
using Test

# Default `Aqua.test_all(UnionArrays)` does not work due to ambiguities
# in upstream packages.
Aqua.test_all(UnionArrays; ambiguities = false)

@testset "Method ambiguity" begin
    Aqua.test_ambiguities(UnionArrays)
end

end  # module
