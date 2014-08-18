module GLText
using ModernGL, GLAbstraction, GLFW

export getfont, build_line_indexes, findline


function getfont()
	standardFont
end

function inittext()
	rootFolder = Pkg.dir() * "/GLText/src/"
	global standardFont = GLFont(rootFolder*"VeraMono")
end
init_after_context_creation(inittext)


include("types.jl")
#include("textField.jl")
#include("render.jl")


end # module
