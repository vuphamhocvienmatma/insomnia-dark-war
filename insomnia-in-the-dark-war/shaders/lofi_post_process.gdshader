shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float exposure : hint_range(0.3, 1.5) = 0.82;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.65;
uniform float grain_intensity : hint_range(0.0, 0.1) = 0.018;
uniform vec3 warm_tint : source_color = vec3(0.98, 0.94, 0.90);
uniform float aberration_amount : hint_range(0.0, 0.01) = 0.0010;
uniform bool eco_mode = false;
uniform float wobble_intensity = 0.0; // Audio-Visual Sync Wobble
uniform float insomnia_level : hint_range(0.0, 1.0) = 0.0;

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 4x4 Bayer Dither Matrix for retro posterization banding reduction
const float bayer[16] = float[](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

vec3 aces_tonemap(vec3 x) {
	const float a = 2.51;
	const float b = 0.03;
	const float c = 2.43;
	const float d = 0.59;
	const float e = 0.14;
	return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void fragment() {
	if (eco_mode) {
		COLOR = texture(screen_texture, SCREEN_UV);
	} else {
		vec2 uv = SCREEN_UV;
		
		vec2 diff = uv - vec2(0.5);
		float dist_sq = dot(diff, diff);

		vec2 ca_offset = diff * dist_sq * aberration_amount * 6.0;
		// Audio-Visual Sync Wobble
		if (wobble_intensity > 0.0) {
			uv.x += sin(TIME * 6.0 + uv.y * 10.0) * wobble_intensity * 0.005;
			uv.y += cos(TIME * 4.0 + uv.x * 12.0) * wobble_intensity * 0.005;
			ca_offset = diff * dist_sq * aberration_amount * (6.0 + wobble_intensity * 10.0);
		}
		
		float r = texture(screen_texture, uv - ca_offset).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv + ca_offset).b;
		vec3 col = vec3(r, g, b);

		// Insomnia Shift
		if (insomnia_level > 0.0) {
			vec2 insom_shift = vec2(sin(TIME * 5.0) * 0.005, cos(TIME * 3.0) * 0.005) * insomnia_level;
			col.r = texture(screen_texture, uv + insom_shift).r;
			col.b = texture(screen_texture, uv - insom_shift).b;
		}
		
		// Apply exposure factor
		col *= exposure;
		
		// ACES filmic tonemapping - compresses overbright peaks into smooth filmic highlights
		col = aces_tonemap(col);
		
		// Rich cozy lofi color grading
		col *= warm_tint;
		
		// Gentle contrast
		col = pow(col, vec3(1.1));
		
		// Subtle film grain
		float noise = (random(uv + vec2(sin(TIME * 10.0), cos(TIME * 15.0))) - 0.5) * 2.0;
		col += noise * grain_intensity;
		
		// Retro Bayer Dithering
		if (wobble_intensity > 0.0) {
			ivec2 frag_coord = ivec2(FRAGCOORD.xy) % 4;
			int dither_idx = frag_coord.y * 4 + frag_coord.x;
			float dither_val = (bayer[dither_idx] / 16.0) - 0.5;
			col += dither_val * 0.05; // Light dither blend
		}
		
		// Smooth vignette
		float vig = smoothstep(0.08, 0.70, dist_sq);
		col = mix(col, col * (1.0 - vignette_opacity), vig * vignette_intensity * 2.0);
		
		COLOR = vec4(col, 1.0);
	}
}
