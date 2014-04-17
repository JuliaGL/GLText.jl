module GLText
using ModernGL, GLUtil, Events

export getFont,GLFont, TextField, StyledTextSegment, TextCursor, FontProperties, buildNewLineIndexes, findLine


immutable StyledTextSegment
	segment::UnitRange{Int}
	style::Dict{ASCIIString, Any}
end
type TextCursor
	x::Float32
	y::Float32
	intend::Float32
end

type TextField
	text::String
	newLineIndexes::Array{UnitRange{Int}, 1}
	styles::Array{StyledTextSegment, 1}
	selection::UnitRange{Int}
	x::Float32
	y::Float32
	function TextField(text::String, x::Real, y::Real)
		defaultStyle 	= Dict{ASCIIString, Any}(["textColor" => Float32[0,0,0,1], "backgroundColor" => Float32[0,0,0,0]])
		styles 			= [StyledTextSegment(1:length(text), defaultStyle)]
		new(text, buildNewLineIndexes(text), styles, length(text):length(text)-1, float32(x), float32(y))
	end

	function TextField(text::String, styles::Array{StyledTextSegment, 1}, x::Real, y::Real)
		new(text, buildNewLineIndexes(text), styles, length(text):length(text)-1, float32(x), float32(y))
	end

	function TextField(text::String,
			styles::Array{StyledTextSegment, 1},
			selection::Range,
			x::Real, y::Real)
		new(text, buildNewLineIndexes(text), styles, selection, float32(x), float32(y))
	end
end

function buildNewLineIndexes(text::String)
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

function findLine(newLineIndexes::Array{UnitRange{Int}, 1}, cursor::Int)
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



type FontProperties
	lineHeight::GLfloat
    advance::GLfloat
end

type GLFont
    properties::FontProperties
    gl::GLRenderObject
	
	function GLFont(name::String)
	    texture             = Texture("$(name).bmp")
	    flStream            = open("$(name).txt")
	    width               = int(readline(flStream))
	    height              = int(readline(flStream))
	    lineHeight::GLfloat = int(readline(flStream))
	    advance::GLfloat 	= 0

	    verts       = Float32[]
	    uv          = Float32[]

	    for line in eachline(flStream)
	        values                  = split(line)
	        charCode                = char(int(values[1]))
	        advance                 = int(values[2])
	        x::GLfloat              = int(values[3]) / width
	        x2::GLfloat             = (int(values[3]) + advance) / width
	        y::GLfloat              = int(values[4]) / height
	        texLineHeight::GLfloat  = lineHeight / height
	        charUV = [
	            x, y + texLineHeight,
	            x, y , 
	            x2, y + texLineHeight, 
	            x2, y+ texLineHeight,
	            x, y ,
	            x2, y]

	        push!(verts, createQuad(0f0, 0f0, advance, lineHeight)...)
	        push!(uv, charUV...)
	    end
	    close(flStream)
	    verts 				= GLBuffer(verts, 2)
	    uv 					= GLBuffer(uv, 2)
	    cam 				= OrthogonalCamera()
	    registerEventAction(EventAction{WindowResized{0}}(x -> true, (), resize, (cam,)))
		data 				= ["position" => verts, "uv" => uv, "fontTexture" => texture, "mvp" => cam]
	    gl 					= GLRenderObject(textShader, data, primitiveMode = GL_TRIANGLES)
	    push!(gl.preRenderFunctions, (enableTransparency, ()))
	    verts 	= 0
	    uv 		= 0
	    new(FontProperties(lineHeight, advance), gl)
	end
end




function getFont()
	standardFont
end


import GLUtil.render


function render(text::String, cursor::TextCursor, font::GLFont, displayableAray::Shape)
	for char in text
        if char == '\t'
        	cursor.x += font.properties.advance * 3
        elseif char == '\r' || char == '\n'
        	cursor.y -= font.properties.lineHeight
         	cursor.x = cursor.intend
        else
            if inside(displayableAray, cursor.x, cursor.y)
                render("charOffset", [cursor.x, cursor.y], font.gl.program.id)
                #in the GLBuffer for the text triangle data, there are six verts per char
    			glDrawArrays(GL_TRIANGLES, int(char) * 6, 6)
            end
            cursor.x += font.properties.advance
        end
    end
end

global selectionStyle = Dict{ASCIIString, Any}(["textColor" => Float32[0,0,0,0], "backgroundColor" => Float32[0.02,0.8,0.01,0.2]])

function render(t::TextField, font::GLFont, displayableAray::Shape = Rectangle(0, 0, 9999999,9999999))
	render(font.gl)

	startLine, line = findLine(t.newLineIndexes, first(t.selection))

	xPosition = first(t.selection) - first(line)
	cursorX = t.x + (xPosition * font.properties.advance)
	cursorY = t.y - ((startLine-1) * font.properties.lineHeight)
	selectionStart =  TextCursor(cursorX, cursorY, 0)
	render(selectionStyle, font.gl.program.id)
	if length(t.selection) < 1
		render("|", TextCursor(cursorX + (font.properties.advance / 2f0), cursorY, 0), font, displayableAray)
	else
		#first approach, just render selection as a blank string with backgroundcolor
		selectionString = map(x -> (x == '\r' || x == '\n') ? x : " ", text[chr2ind(t.text, t.selection.start):chr2ind(t.text, last(t.selection))])
		render(selectionString, TextCursor(cursorX, cursorY, 0), font, displayableAray)
	end
	startCursor = TextCursor(t.x, t.y, t.x)

	for elem in t.styles
		# assert range is in text range
		segment = intersect(elem.segment, 1:length(t.text))
		@assert segment.start <= last(segment)
		
		render(elem.style, font.gl.program.id)

		render(t.text[chr2ind(t.text, segment.start):chr2ind(t.text, last(segment))], startCursor, font, displayableAray)
	end
end






function initGLText()
	rootFolder = Pkg.dir() * "/GLText/src/"
	global textShader   = GLProgram(rootFolder*"textShader") 
	global standardFont = GLFont(rootFolder*"VeraMono")
end
initAfterContextCreation(initGLText)

end # module
