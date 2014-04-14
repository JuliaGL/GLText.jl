#version 110
// Input vertex data, different for all executions of this shader.
attribute vec2 position;
attribute vec2 uv;

varying vec2 v_textureCoordinate;

// Values that stay constant for the whole mesh.
uniform mat4 mvp;
uniform vec2 charOffset;

void main(){

	gl_Position = mvp * vec4(position + charOffset, 0, 1);
	
	// UV of the vertex. No special space for this one.
	v_textureCoordinate = uv;
}

