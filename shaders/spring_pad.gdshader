shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform float dip = 0.0;

void vertex() {
	float base_top = -0.30;
	float plate_bottom = 0.25;
	float coil = plate_bottom - base_top;
	float squash = 1.0;
	if (dip >= 0.0) {
		squash = mix(1.0, 0.32, dip);
	} else {
		squash = mix(1.0, 1.18, clamp(-dip / 0.28, 0.0, 1.0));
	}
	float drop = coil * (1.0 - squash);
	if (VERTEX.y >= plate_bottom) {
		VERTEX.y -= drop;
	} else if (VERTEX.y > base_top) {
		float t = (VERTEX.y - base_top) / coil;
		VERTEX.y = base_top + t * coil * squash;
	}
}

void fragment() {
	ALBEDO = texture(albedo, UV).rgb;
	ROUGHNESS = 0.48;
}
