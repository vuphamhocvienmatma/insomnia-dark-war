shader_type canvas_item;
uniform sampler2D noise_tex : repeat_enable;
uniform float speed = 1.5;
uniform float strength = 0.03;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 noise_uv = UV + vec2(0.0, TIME * speed);
	vec4 noise_val = texture(noise_tex, noise_uv);
	// Displacement based on noise
	vec2 disp = vec2(noise_val.r - 0.5, noise_val.g - 0.5) * strength;
	// Fade out distortion at the edges of the rect
	float edge_fade = smoothstep(0.0, 0.2, UV.x) * smoothstep(1.0, 0.8, UV.x) * smoothstep(0.0, 0.2, UV.y) * smoothstep(1.0, 0.8, UV.y);
	vec4 bg = texture(screen_texture, SCREEN_UV + disp * edge_fade);
	COLOR = bg;
}
