shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.0;
uniform float desaturate_amount : hint_range(0.0, 1.0) = 0.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.0;
uniform float aberration_amount : hint_range(0.0, 10.0) = 0.0;

// Radial Clarity Mask
uniform vec2 cabin_screen_pos = vec2(0.5, 0.5);
uniform float clarity_radius_uv = 0.2;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Chromatic Aberration
    float r = texture(SCREEN_TEXTURE, uv - vec2(aberration_amount * 0.001, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv + vec2(aberration_amount * 0.001, 0.0)).b;
    vec3 color = vec3(r, g, b);
    
    // Clarity Mask
    float mask_dist = distance(uv, cabin_screen_pos);
    float clarity = smoothstep(clarity_radius_uv * 0.5, clarity_radius_uv, mask_dist);
    
    // Desaturate
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(color, vec3(luminance), desaturate_amount * clarity);
    
    // Tint
    float final_tint = tint_amount * clarity;
    color = mix(desaturated, tint_color.rgb, final_tint);
    
    // Vignette
    vec2 center = uv - 0.5;
    float dist = length(center);
    float vignette = smoothstep(0.8, 0.2, dist * (1.0 + vignette_intensity));
    color *= vignette;
    
    // Grain
    float noise = hash(uv * TIME) * 2.0 - 1.0;
    color += noise * grain_amount;
    
    COLOR = vec4(color, 1.0);
}
