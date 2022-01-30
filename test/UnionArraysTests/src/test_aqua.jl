module TestAqua

import Aqua
import UnionArrays
using Test

# Default `Aqua.test_all(UnionArrays)` does not work due to ambiguities
# in upstream packages.
function test_aqua()
    Aqua.test_all(UnionArrays; ambiguities = false)
end

function test_method_ambiguity()
    Aqua.test_ambiguities(UnionArrays)
end

end  # module
