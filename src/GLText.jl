module GLText
using ModernGL, GLUtil, Events

export getFont,GLFont, TextField, StyledTextSegment, TextCursor, FontProperties


immutable StyledTextSegment
	segment::Range
	style::Dict{ASCIIString, Any}
end
type TextCursor
	x::Float32
	y::Float32
	intend::Float32
end
type TextField
	text::String
	styles::Array{StyledTextSegment, 1}
	selection::Range
	lines::Int
	x::Float32
	y::Float32
	cursor::Int

	function TextField(text::String, x, y)
		lines 			= count(x -> x == '\n' || x == '\r', text) + 1
		defaultStyle 	= Dict{ASCIIString, Any}(["textColor" => Float32[0,0,0,1], "backgroundColor" => Float32[0,0,0,0]])
		styles 			= [StyledTextSegment(1:length(text), defaultStyle)]
		new(text, styles, length(text):length(text), lines, x, y, length(text))
	end

	function TextField(text::String, styles::Array{StyledTextSegment, 1}, x, y)
		lines 			= count(char -> char == '\n' || char == '\r', text)
		new(text, styles, length(text):length(text), lines, x, y, length(text))
	end

	function TextField(text::String,
			styles::Array{StyledTextSegment, 1},
			selection::Range,
			lines::Int,
			x, y)
		new(text, styles, selection, lines, x, y, length(text))
	end
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
function render(t::TextField, font::GLFont, displayableAray::Shape = Rectangle(0, 0, 9999999,9999999))
	render(font.gl)
	startCursor = TextCursor(t.x, t.y, t.x)
	for elem in t.styles
		# assert range is in text range
		segment = intersect(elem.segment, 1:length(t.text))

		@assert segment.start <= last(segment)
		for style in elem.style
			render(style..., font.gl.program.id)
		end
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
