{{GLSL_VERSION}}

in float        frag_x;
in vec2        frag_uv;
in vec4 	   frag_color;
in vec4 	   frag_backgroundcolor;

flat in uvec2  frag_objectid;

uniform sampler2D  dontdelete_font_texture;

out vec4 	   fragment_color;
out uvec2 	   fragment_groupid;

void main(){

	float 	alphaAbove	= texture(dontdelete_font_texture, frag_uv).r;
	float 	textAlpha 	= alphaAbove * frag_color.a;
	vec3 	color 		= mix(frag_backgroundcolor.rgb, frag_color.rgb, alphaAbove);
	float 	alpha 		= min(1.0 , frag_backgroundcolor.a + (1.0 - frag_backgroundcolor.a) * textAlpha);

	fragment_color 		= vec4(color, alpha);
	if (frag_x > 0.5) // move boundaries for text selection to the middle of the glyp
		fragment_groupid 	= frag_objectid;
	else
		fragment_groupid 	= frag_objectid - uvec2(0,1);
}	