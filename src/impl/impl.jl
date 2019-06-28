module Impl

using Base: Dims
using Transducers
using Transducers: @return_if_reduced, next, complete

using ..Abstract

include("utils.jl")
include("vectors.jl")
include("arrays.jl")
include("reducibles.jl")

end  # module
