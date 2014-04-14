#version 110

varying vec2 v_textureCoordinate;
uniform vec4 textColor;
uniform vec4 backgroundColor;
uniform sampler2D fontTexture;

void main(){

	float 	alphaAbove	= (texture2D(fontTexture, v_textureCoordinate)).x;
	float 	textAlpha 	= alphaAbove * textColor.a;
	vec3 	color 		= mix(backgroundColor.rgb, textColor.rgb, alphaAbove);
	float 	alpha 		= min(1.0 , backgroundColor.a + (1.0 - backgroundColor.a) * textAlpha);

	gl_FragColor = vec4(color, alpha);
}