module GLText
using ModernGL
using GLAbstraction
using GLFW
using Compat

export getfont, build_line_indexes, findline


function getfont()
	standardFont
end

function inittext()
	global standardFont = GLFont(Pkg.dir("GLText", "src", "VeraMono"))
end
init_after_context_creation(inittext)


include("types.jl")
#include("textField.jl")
#include("render.jl")


end # module
