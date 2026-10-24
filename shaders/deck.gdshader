shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.42, 0.42, 0.42, 1.0);
uniform float roughness_amt = 0.92;
uniform float metal = 0.0;
uniform float rim = 0.055;

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float up = smoothstep(0.25, 0.82, clamp(world_normal.y, 0.0, 1.0));
	float face = mix(0.74, 1.0, up);
	vec2 uv = UV;
	float edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	float lip = smoothstep(0.0, rim, edge);
	float grain = fract(sin(dot(floor(world_pos.xz * 1.7), vec2(127.1, 311.7))) * 43758.5);
	float blot = sin(world_pos.x * 0.31) * sin(world_pos.z * 0.23);
	float shade = face * (0.96 + blot * 0.025 + (grain - 0.5) * 0.035);
	shade *= mix(0.62, 1.0, lip);
	ALBEDO = albedo.rgb * shade;
	ROUGHNESS = roughness_amt;
	METALLIC = metal;
}
