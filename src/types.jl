export GLFont

immutable GLFont
    data::Dict{Symbol, Any}
	props::Vector{Vec2}
	function GLFont(name::String)
	    flStream            = open("$(name).txt")
	    width               = parse(Int, readline(flStream))
	    height              = parse(Int, readline(flStream))
	    lineHeight::GLfloat = parse(Int, readline(flStream))
	    advance::GLfloat 	= 0

	    values                   = split(readline(flStream))
        charCodet                = @compat(Char(parse(Int, values[1])))
        advancet                 = parse(Int, values[2])
        xt::GLfloat              = parse(Int, values[3]) / width
        x2t::GLfloat             = (parse(Int, values[3]) + advance) / width
        yt::GLfloat              =  ((height - parse(Int, values[4])  - lineHeight) / height)
        texLineHeightt::GLfloat  = lineHeight / height

        tmp_uv 	  = Array(Vec2, 1, 5)
        tmp_uv[1] = Vec2(advancet, lineHeight)
        tmp_uv[2] = Vec2(xt,  yt)
        tmp_uv[3] = Vec2(xt,  yt + texLineHeightt)
        tmp_uv[4] = Vec2(x2t, yt + texLineHeightt)
        tmp_uv[5] = Vec2(x2t, yt)

	    uv = vcat(tmp_uv)
	    i = 1
	    for line in eachline(flStream)
	        values                  = split(line)
	        charCode                = @compat(Char(parse(Int, values[1])))
	        advance                 = parse(Int, values[2])
	        x::GLfloat              = parse(Int, values[3]) / width
	        x2::GLfloat             = (parse(Int, values[3]) + advance) / width
	        y::GLfloat              = ((height - parse(Int, values[4]) - lineHeight) / height) 
	        texLineHeight::GLfloat  = lineHeight / height
	        tmp_uv[1] = Vec2(advance, lineHeight)
	        tmp_uv[2] = Vec2(x,  y)
	        tmp_uv[3] = Vec2(x,  y + texLineHeight)
	        tmp_uv[4] = Vec2(x2, y + texLineHeight)
	        tmp_uv[5] = Vec2(x2, y)
	        uv = vcat(uv, tmp_uv)
	        i += 1
	    end
	    close(flStream)
		data = @compat Dict{Symbol, Any}(
			:dontdelete_uv_index 		=> GLBuffer(GLint[1:6;]), 
			:dontdelete_indexes 		=> indexbuffer(GLuint[0:5;]), 
			:dontdelete_uv 				=> Texture(uv), 
			:dontdelete_font_texture 	=> Texture("$(name).bmp")
		)
	    new(data, vec(uv[1,:]))
	end
end
