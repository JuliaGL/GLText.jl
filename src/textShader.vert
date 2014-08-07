{{GLSL_VERSION}}
// Input vertex data, different for all executions of this shader.
{{in}} vec2 vertex;
{{in}} vec2 uv;

{{out}} vec2 frag_uv;

// Values that stay constant for the whole mesh.
uniform mat4 mvp;

uniform vec3 offset;
uniform vec3 normal;

vec3 qmult(vec4 q, vec3 v) 
{
    vec3 t = 2 * cross(Vector3(q.x, q.y, q.z), v);
    return v + q.x * t + cross(Vector3(q.y, q.z, q.w), t);
}

void main(){

	gl_Position = mvp * vec4(qmult(vertex, 0, 1);
	
	// UV of the vertex. No special space for this one.
	frag_uv = uv;
}

