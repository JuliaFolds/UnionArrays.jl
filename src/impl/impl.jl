module Impl

using Base: Dims
using Transducers
using Transducers: @return_if_reduced

using ..Abstract

include("utils.jl")
include("vectors.jl")
include("arrays.jl")

end  # module
