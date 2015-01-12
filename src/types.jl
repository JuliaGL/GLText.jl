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
		defaultStyle 	= @compat Dict{ASCIIString, Any}("textColor" => Float32[1,1,1,1], "backgroundColor" => Float32[0,0,0,0])
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

immutable GLFont
    data::Dict{Symbol, Any}
	props::Vector{Vec2}
	function GLFont(name::String)
	    flStream            = open("$(name).txt")
	    width               = int(readline(flStream))
	    height              = int(readline(flStream))
	    lineHeight::GLfloat = int(readline(flStream))
	    advance::GLfloat 	= 0

	    values                   = split(readline(flStream))
        charCodet                = char(int(values[1]))
        advancet                 = int(values[2])
        xt::GLfloat              = int(values[3]) / width
        x2t::GLfloat             = (int(values[3]) + advance) / width
        yt::GLfloat              =  ((height - int(values[4])  - lineHeight) / height)
        texLineHeightt::GLfloat  = lineHeight / height
        a = Vec2[Vec2(advancet, lineHeight) Vec2(xt,  yt) Vec2(xt,  yt + texLineHeightt) Vec2(x2t, yt + texLineHeightt) Vec2(x2t, yt)]
	        println("va: ", typeof(a))
	        println("va: ", size(a))
	    uv = vcat(a)
	    i = 1
	    for line in eachline(flStream)
	        values                  = split(line)
	        charCode                = char(int(values[1]))
	        advance                 = int(values[2])
	        x::GLfloat              = int(values[3]) / width
	        x2::GLfloat             = (int(values[3]) + advance) / width
	        y::GLfloat              = ((height - int(values[4]) - lineHeight) / height) 
	        texLineHeight::GLfloat  = lineHeight / height
	        a = Vec2[Vec2(advance, lineHeight) Vec2(x,  y) Vec2(x,  y + texLineHeight) Vec2(x2, y + texLineHeight) Vec2(x2, y)]
	        uv = vcat(uv, a)
	        i += 1
	    end
	    close(flStream)
	    println("size of uv: ", size(uv))
	    println("type of uv: ", typeof(uv))
		data = @compat Dict{Symbol, Any}(
			:dontdelete_uv_index 		=> GLBuffer(GLint[1:6], 1), 
			:dontdelete_indexes 		=> indexbuffer(GLuint[0:5]), 
			:dontdelete_uv 				=> Texture(uv), 
			:dontdelete_font_texture 	=> Texture("$(name).bmp")
		)
	    new(data, vec(uv[1,:]))
	end
end
