#version 110

varying vec2 uv_o;
uniform sampler2D fontTexture;


void main(){


	gl_FragColor = vec4(1,0,1,(texture2D(fontTexture, uv_o)).x);
}
