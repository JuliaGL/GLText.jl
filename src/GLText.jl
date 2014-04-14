module GLText
using ModernGL, GLUtil

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
		data 				= ["position" => verts, "uv" => uv, "fontTexture" => texture, "mvp" => cam]
	    gl 					= GLRenderObject(textShader, data, primitiveMode = GL_TRIANGLES)
	    push!(gl.preRenderFunctions, (enableTransparency, ()))
	    verts 	= 0
	    uv 		= 0
	    new(lineHeight, advance, gl)
	end
end


function initGLText()
	rootFolder = Pkg.dir() * "\\GLText\\src\\"
	global textShader   = GLProgram(rootFolder*"textShader") 
	global standardFont = GLFont(rootFolder*"VeraMono")
end
function getFont()
	standardFont
end
export getFont,GLFont
initAfterContextCreation(initGLText)

end # module
