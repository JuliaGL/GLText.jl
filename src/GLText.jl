module GLText
using ModernGL, GLAbstraction, GLFW

export getfont, build_line_indexes, findline


function build_line_indexes(text::String)
	newLineIndexes = UnitRange{Int}[]
	index = 0
	for elem in text
		if elem == '\n' || elem == '\r'
			if isempty(newLineIndexes)
				push!(newLineIndexes, 1:index)
			else
				lastIndex = last(newLineIndexes[end]) + 2
				push!(newLineIndexes, lastIndex:index)
			end
			lineLength = 0
		end
		index += 1
	end
	if isempty(newLineIndexes)
		push!(newLineIndexes, 1:length(text))
	else
		lastIndex = last(newLineIndexes[end]) + 2
		push!(newLineIndexes, lastIndex:length(text))
	end
	newLineIndexes
end

function findline(newLineIndexes::Array{UnitRange{Int}, 1}, cursor::Int)
	currentLine 		= newLineIndexes[1]
	index 				= 1
	for elem in newLineIndexes
		if in(cursor, first(elem)-1:last(elem))
			return index, elem
		end
		index += 1
	end
	return index, currentLine
end



function getfont()
	standardFont
end




#function inittext()
#	rootFolder = Pkg.dir() * "/GLText/src/"
#	global textShader   = TemplateProgram(rootFolder*"textShader") 
#	global standardFont = GLFont(rootFolder*"VeraMono")
#end
#initAfterContextCreation(inittext)


include("types.jl")
#include("textField.jl")
#include("render.jl")


end # module
