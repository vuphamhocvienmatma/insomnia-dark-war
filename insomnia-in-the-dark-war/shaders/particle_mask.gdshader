shader_type canvas_item;

uniform vec2 cabin_screen_pos = vec2(0.5, 0.5);
uniform float clarity_radius_uv = 0.2;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float d = distance(SCREEN_UV, cabin_screen_pos);
    float a = smoothstep(clarity_radius_uv * 0.65, clarity_radius_uv, d);
    COLOR = vec4(c.rgb, c.a * a);
}

