shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec3 a0;
uniform vec3 a1;
uniform vec3 b0;
uniform vec3 b1;
uniform vec3 c0;
uniform vec3 c1;
uniform vec3 d0;
uniform vec3 d1;
uniform float arm_radius = 0.18;
uniform float hide_near = 0.16;

varying vec3 world_pos;

float _seg(vec3 p, vec3 from, vec3 to) {
	vec3 span = to - from;
	float denom = dot(span, span);
	float t = denom < 0.0001 ? 0.0 : clamp(dot(p - from, span) / denom, 0.0, 1.0);
	return distance(p, from + span * t);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float nearest = _seg(world_pos, a0, a1);
	nearest = min(nearest, _seg(world_pos, b0, b1));
	nearest = min(nearest, _seg(world_pos, c0, c1));
	nearest = min(nearest, _seg(world_pos, d0, d1));
	if (nearest > arm_radius || length(VERTEX) < hide_near) {
		discard;
	}
	vec4 tex = texture(albedo_tex, UV);
	ALBEDO = tex.rgb * albedo_color.rgb;
	ROUGHNESS = 0.62;
}
