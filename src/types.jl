export GLFont, TextField, StyledTextSegment, TextCursor, FontProperties

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
	id::Symbol
	text::UTF8String
	newLineIndexes::Array{UnitRange{Int}, 1}
	#words::Array{SubString, 1}
	styles::Array{StyledTextSegment, 1}
	selection::UnitRange{Int}
	x::Float32
	y::Float32
	area::Shape
	hasFocus::Bool
	function TextField(id::Symbol, text::String, x::Real, y::Real, area::Shape)
		defaultStyle 	= Dict{ASCIIString, Any}(["textColor" => Float32[1,1,1,1], "backgroundColor" => Float32[0,0,0,0]])
		styles 			= [StyledTextSegment(1:length(text), defaultStyle)]
		new(id, utf8(text), build_line_indexes(text), styles, length(text) : length(text)-1, float32(x), float32(y), area, false)
	end

	function TextField(id::Symbol,text::String, styles::Array{StyledTextSegment, 1}, x::Real, y::Real, area::Shape)
		new(id, utf8(text), build_line_indexes(text), styles, length(text):length(text)-1, float32(x), float32(y), area, false)
	end

	function TextField(id::Symbol,text::String,
			styles::Array{StyledTextSegment, 1},
			selection::Range,
			x::Real, y::Real, area::Shape)
		new(id, utf8(text), build_line_indexes(text), styles, selection, float32(x), float32(y), area, false)
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
	    registerEventAction(EventAction{WindowResized{Window}}(x -> true, (), resize, (cam,)))
		data 				= ["position" => verts, "uv" => uv, "fontTexture" => texture, "mvp" => cam]
	    gl 					= GLRenderObject(textShader, data)
	    push!(gl.preRenderFunctions, (enableTransparency, ()))
	    verts 	= 0
	    uv 		= 0
	    new(FontProperties(lineHeight, advance), gl)
	end
end
