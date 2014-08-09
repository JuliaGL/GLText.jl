using GLWindow, GLAbstraction, ImmutableArrays, GLFW, React, ModernGL, Quaternions, GLText, GLPlot, Images

window 	= createwindow("Mesh Display", 1000, 1000, debugging = false) # debugging just works on linux and windows
cam 	= PerspectiveCamera(window.inputs, Vec3(1,1,1), Vec3(0))


initplotting()

function textwithoffset(start::Vec3, text, advance, lineHeight)
	resulttext 	= Vec1[]
	offset 		= Vec3[start]
	for elem in text
		offset1 = last(offset)
		if elem == '\t'
        	offset[end] = Vec3(offset1[1] + advance * 3, offset1[2], 0f0)
        elseif  elem == ' '
        	offset[end] = Vec3(offset1[1] + advance, offset1[2], 0f0)
        elseif elem == '\r' || elem == '\n'
        	offset[end] = Vec3(start[1], offset1[2] - lineHeight, 0f0)
        else
        	glchar = float32(elem)
        	if glchar > 256 
        		glchar = float32(0)
        	end
			push!(offset, Vec3(offset1[1] + advance, offset1[2], 0f0))
			push!(resulttext, Vector1(glchar))
        end
	end
	offset, resulttext
end


text = "ööähh Hallo, was ist denn hier los?#üa+#üsadi0ß24 \nakjskljd ="
font = GLFont("VeraMono")
offset, ctext 	= textwithoffset(Vec3(0), text, font.props[1]...)
println(offset)

parameters 		= [(GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),(GL_TEXTURE_MIN_FILTER, GL_NEAREST)]
texttex 		= Texture(ctext, parameters=parameters)
offset 			= Texture(offset, parameters=parameters)

view = [
  "GLSL_EXTENSIONS"     	=> "#extension GL_ARB_draw_instanced : enable",
  "offset_calculation"     => "texelFetch(offset, index, 0).rgb;",
]


data = merge([
	:index_offset		=> convert(GLint, 0),
    :rotation 			=> Vec4(1,0,0,0),
    :text 				=> texttex,
    :offset 			=> offset,
    :scale 				=> Vec2(1/500),
    :color 				=> Vec4(0,0,0,1),
    :backgroundcolor 	=> Vec4(0),
    :projectionview 	=> cam.projectionview
], font.data)


program = TemplateProgram("textShader.vert", "textShader.frag", view, data)
obj = instancedobject(data, program, length(text))
#prerender!(obj, glEnable, GL_DEPTH_TEST)
obj2 = toopengl(Texture("VeraMono.bmp"))

glClearColor(1,1,1,0)
while !GLFW.WindowShouldClose(window.glfwWindow)
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  render(GRID)
  render(obj)
  #render(obj2)

  yield() # this is needed for react to work
  GLFW.SwapBuffers(window.glfwWindow)
  GLFW.PollEvents()
end
GLFW.Terminate()



