module GLText
using ModernGL, GLUtil, MutableStrings, Events

export getFont,GLFont, TextField, StyledTextSegment, TextCursor


immutable StyledTextSegment
	offset::Int
	endof::Int
	style::Dict{ASCIIString, Any}
end
type TextCursor
	intend::Float32
	x::Float32
	y::Float32
end
type TextField
	text::MutableASCIIString
	styles::Array{StyledTextSegment, 1}
	selection::StyledTextSegment
	lines::Int
	start::TextCursor
end



type GLFont
    lineHeight::GLfloat
    advance::GLfloat
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
	    new(lineHeight, advance, gl)
	end
end


function initGLText()
	rootFolder = Pkg.dir() * "/GLText/src/"
	global textShader   = GLProgram(rootFolder*"textShader") 
	global standardFont = GLFont(rootFolder*"VeraMono")
end
function getFont()
	standardFont
end

initAfterContextCreation(initGLText)

import GLUtil.render


function render(text::Union(MutableASCIIString, ASCIIString), cursor::TextCursor, font::GLFont, displayableAray::Shape)
	for char in text
        if char == '\t'
        	cursor.x += font.advance * 3
        elseif char == '\r' || char == '\n'
        	cursor.y -= font.lineHeight
         	cursor.x = cursor.intend
        else
            if inside(displayableAray, cursor.x, cursor.y)
                render("charOffset", [cursor.x, cursor.y], font.gl.program.id)
                #in the GLBuffer for the text triangle data, there are six verts per char
    			glDrawArrays(GL_TRIANGLES, int(char) * 6, 6)
            end
            cursor.x += font.advance
        end
    end
end
function render(t::TextField, font::GLFont, displayableAray::Shape = Rectangle(0, 0, 9999999,9999999))
	startCursor = deepcopy(t.start)
	for elem in t.styles
		@assert elem.offset > 0
		@assert elem.endof <= length(t.text)

		for style in elem.style
			render(style..., font.gl.program.id)
		end
		render(t.text[elem.offset:elem.endof], startCursor, font, displayableAray)
	end
end

end # module
