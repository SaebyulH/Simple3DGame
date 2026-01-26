shader_type spatial;
render_mode unshaded, fog_disabled;

uniform int value_steps : hint_range(2, 64) = 8;
uniform float shadow_bias : hint_range(0.5, 4.0) = 2.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

vec3 rgb_to_hsv(vec3 c) {
	float cmax = max(c.r, max(c.g, c.b));
	float cmin = min(c.r, min(c.g, c.b));
	float delta = cmax - cmin;

	float h = 0.0;
	if (delta > 0.0) {
		if (cmax == c.r) {
			h = mod((c.g - c.b) / delta, 6.0);
		} else if (cmax == c.g) {
			h = ((c.b - c.r) / delta) + 2.0;
		} else {
			h = ((c.r - c.g) / delta) + 4.0;
		}
		h /= 6.0;
	}

	float s = cmax == 0.0 ? 0.0 : delta / cmax;
	float v = cmax;

	return vec3(h, s, v);
}

vec3 hsv_to_rgb(vec3 c) {
	float h = c.x * 6.0;
	float s = c.y;
	float v = c.z;

	int i = int(floor(h));
	float f = h - float(i);

	float p = v * (1.0 - s);
	float q = v * (1.0 - f * s);
	float t = v * (1.0 - (1.0 - f) * s);

	if (i == 0) return vec3(v, t, p);
	if (i == 1) return vec3(q, v, p);
	if (i == 2) return vec3(p, v, t);
	if (i == 3) return vec3(p, q, v);
	if (i == 4) return vec3(t, p, v);
	return vec3(v, p, q);
}

void fragment() {
	vec3 screen_rgb = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 hsv = rgb_to_hsv(screen_rgb);

	// Correct: finer steps in shadows
	float v = pow(hsv.z, 1.0 / shadow_bias);
	v = floor(v * float(value_steps)) / float(value_steps);
	hsv.z = pow(v, shadow_bias);

	ALBEDO = hsv_to_rgb(hsv);
}
