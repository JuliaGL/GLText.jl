{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

// Input vertex data, different for all executions of this shader.
{{in}} int uv_index;


// Values that stay constant for the whole mesh.

{{offset_type}} offset;
{{rotation_type}} rotation;

{{scale_type}} scale;

{{color_type}} color;
{{backgroundcolor_type}} backgroundcolor;
//{{style_type}} style;


uniform int index_offset;
uniform sampler1D text;
uniform sampler2D uv;

uniform mat4 projectionview;

{{out}} vec2 frag_uv;
{{out}} vec4 frag_backgroundcolor;
{{out}} vec4 frag_color;

vec3 qmult(vec4 q, vec3 v) 
{
    vec3 t = 2 * cross(vec3(q.y, q.z, q.w), v);
    return v + q.x * t + cross(vec3(q.y, q.z, q.w), t);
}

const int SPACE = 32;

void main(){

	int index 		= gl_InstanceID;
	int glyph 		= int(texelFetch(text, index, 0).r);

	vec2 glyph_prop	= texelFetch(uv, ivec2(glyph, 0), 0).xy; // lineheigt + advance
	vec2 vertex 	= vec2(0.0); // if uv_index is vert 1 or 6
	int  uv_index2  = 1;
	if (uv_index == 2)
	{
		uv_index2 = 2;
		vertex.y = glyph_prop.y;
	}
	else if  ((uv_index == 3) || (uv_index == 4))
	{
		uv_index2 = 3;
		vertex = glyph_prop;
	}
	else if (uv_index == 5)
	{
		uv_index2 = 4;
		vertex.x = glyph_prop.x;
	}
	vec4 rotationq 		= {{rotation_calculation}}
	vec2 scalevec 		= {{scale_calculation}}
	vec3 offsetvec 		= {{offset_calculation}}

	vec3 vertexvec 	= vec3(vertex * scalevec, 0) + (offsetvec *vec3(scalevec,1));
	gl_Position 	= projectionview * vec4((qmult(rotationq, vec3(vertex,0)) + offsetvec) * vec3(scalevec,1), 1);
	
	float hcol = 0.0;
	if(104 == texelFetch(text, index, 0).r)
		hcol = 0.5;
	//frag outs
	frag_color 			 = {{color_calculation}}
	frag_backgroundcolor = {{backgroundcolor_calculation}}
	frag_uv			 	 = texelFetch(uv, ivec2(glyph, uv_index2), 0).xy; // uvs are saved in 2*4*256 texture, 2 uv coordinates 4 vertices, 256 chars

}

