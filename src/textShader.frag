{{GLSL_VERSION}}

{{in}} vec2 frag_uv;
uniform vec4 text_color;
uniform vec4 background_color;
uniform sampler2D font_texture;

{{out}} vec4 fragment_color;

void main(){

	float 	alphaAbove	= (texture2D(font_texture, frag_uv)).x;
	float 	textAlpha 	= alphaAbove * text_color.a;
	vec3 	color 		= mix(backgroundColor.rgb, text_color.rgb, alphaAbove);
	float 	alpha 		= min(1.0 , backgroundColor.a + (1.0 - backgroundColor.a) * textAlpha);

	fragment_color 		= vec4(color, alpha);
}