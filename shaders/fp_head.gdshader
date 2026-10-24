shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, hint_default_white;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D emission_tex : source_color, filter_linear_mipmap, hint_default_black;
uniform vec3 emission_color : source_color = vec3(0.0);
uniform float emission_energy = 0.0;
uniform float roughness_amount = 1.0;
uniform float metallic_amount = 0.0;
uniform vec3 head_pos = vec3(0.0);
uniform vec3 head_bone = vec3(0.0);
uniform vec3 neck_pos = vec3(0.0, -1.0, 0.0);
uniform float hide_radius = 0.5;
uniform float camera_reach = 1.35;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// The eyes sit inside the skull. Drop those fragments for that camera only.
	// A camera a few meters back, like the big screens, still sees the head.
	if (distance(CAMERA_POSITION_WORLD, head_pos) < camera_reach) {
		float from_center = distance(world_pos, head_pos);
		float from_bone = distance(world_pos, head_bone);
		float from_neck = distance(world_pos, neck_pos);
		if (from_center < hide_radius && from_bone <= from_neck + 0.02) {
			discard;
		}
	}
	vec4 tex = texture(albedo_tex, UV);
	ALBEDO = tex.rgb * albedo_color.rgb;
	ROUGHNESS = roughness_amount;
	METALLIC = metallic_amount;
	EMISSION = texture(emission_tex, UV).rgb * emission_color * emission_energy;
}
