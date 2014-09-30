{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

// Input vertex data, different for all executions of this shader.
{{in}} int uv_index;

// Values that stay constant for the whole mesh.

{{offset_type}} offset;

{{color_type}} color;
{{backgroundcolor_type}} backgroundcolor;
//{{style_type}} style;

uniform uint objectid;

//uniform int index_offset;
{{text_type}} text;


uniform sampler2D uv;

uniform mat4 projectionview, model;

{{out}} vec2 frag_uv;
{{out}} vec4 frag_backgroundcolor;
{{out}} vec4 frag_color;
flat {{out}} uvec2 frag_objectid;

int texturewidth(usampler1D x)
{
	return textureSize(x, 0);
}
int texturewidth(sampler1D x)
{
	return textureSize(x, 0);
}
int texturewidth(usampler2D x)
{
	return textureSize(x, 0).x;
}
int texturewidth(sampler2D x)
{
	return textureSize(x, 0).x;
}
vec3 qmult(vec4 q, vec3 v) 
{
    vec3 t = 2 * cross(vec3(q.y, q.z, q.w), v);
    return v + q.x * t + cross(vec3(q.y, q.z, q.w), t);
}

int fetchglyph(usampler1D glyphs, int index)
{
	return int(texelFetch(glyphs, index, 0).r);
}
int fetchglyph(usampler2D glyphs, int index)
{
	int width = texturewidth(glyphs);
	return int(texelFetch(glyphs, ivec2(index % width, index/width), 0).r);
}
vec3 position(int index, sampler2D offset)
{
	int width = texturewidth(offset);
	return texelFetch(offset, ivec2(index % width, index / width), 0).xyz;
}

vec3 position(int index, sampler1D offset)
{
	int width 		= texturewidth(offset);
	int line 		= index % width;
	int linepos		= index / width;
	vec3 advance 	= texelFetch(offset, line, 0).xyz;
	vec3 newline 	= texelFetch(offset, line, 0).xyz;

	return (line*newline) + (linepos*advance);
}

vec3 position(int index, mat3x2 offset)
{
	int width 		= texturewidth(text);
	int linepos		= index / width;
	int line 		= index % width;
	vec3 advance 	= vec3(offset[0].x, 0, 0);
	vec3 newline 	= vec3(0, offset[2].x*1.5 , 0); //offset[0].xyz;
	
	return (line*newline) + (linepos*advance);
}
vec3 position(int index, vec3 offset)
{
	return index*offset;
}

const int SPACE = 32;

void main(){

	int index 		   = gl_InstanceID;
	int glyph 		   = fetchglyph(text, index);
	vec3 glyphposition = position(index, offset);

	vec3 glyph_prop	= vec3(24, 12, 0); // lineheigt + advance
	vec3 vertex 	= glyphposition; // if uv_index is vert 1 or 6
	int  uv_index2  = 1;
	if (uv_index == 2)
	{
		uv_index2 = 2;
		vertex = glyphposition + vec3(0,24,0);
	}
	else if  ((uv_index == 3) || (uv_index == 4))
	{
		uv_index2 = 3;
		vertex = glyphposition + vec3(12, 24,0);
	}
	else if (uv_index == 5)
	{
		uv_index2 = 4;
		vertex = glyphposition + vec3(12,0,0);
	}

	gl_Position 		 = projectionview * model * vec4(vertex, 1);
	
	//frag outs
	frag_color 			 = {{color_calculation}};
	frag_backgroundcolor = {{backgroundcolor_calculation}}
	frag_uv			 	 = texelFetch(uv, ivec2(glyph, uv_index2), 0).xy; // uvs are saved in 2*4*256 texture, 2 uv coordinates 4 vertices, 256 chars
	frag_objectid 		 = uvec2(objectid, index);
}

