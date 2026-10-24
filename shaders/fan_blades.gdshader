shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform float spin = 0.0;

void vertex() {
	float r = length(VERTEX.xz);
	bool rotor = r < 0.64 && VERTEX.y > 0.02 && VERTEX.y < 0.50;
	if (rotor) {
		float s = sin(spin);
		float c = cos(spin);
		VERTEX.xz = vec2(c * VERTEX.x - s * VERTEX.z, s * VERTEX.x + c * VERTEX.z);
		NORMAL.xz = vec2(c * NORMAL.x - s * NORMAL.z, s * NORMAL.x + c * NORMAL.z);
	}
}

void fragment() {
	ALBEDO = texture(albedo, UV).rgb;
	ROUGHNESS = 0.45;
}
