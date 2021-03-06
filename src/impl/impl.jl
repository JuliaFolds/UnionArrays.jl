module Impl

import Adapt
using Base: Dims
using Transducers
using Transducers: @return_if_reduced, next, complete
using Setfield: @set  # using Setfield instead of Accessors for older Julia

using ..UnionArrays: Abstract, UnionArrays, buffereltypefor

include("utils.jl")
include("vectors.jl")
include("arrays.jl")
include("reducibles.jl")

end  # module
