module Utils

compile_enabled() = Base.JLOptions().compile_enabled == 1
# allow `== 2` (`--compile=all`) as well?

end  # module
