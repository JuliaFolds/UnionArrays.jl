using UnionArrays
using Test

const COMPILE_ENABLED = Base.JLOptions().compile_enabled == 1
# allow `== 2` (`--compile=all`) as well?
