shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.6;
uniform float radius : hint_range(0.0, 1.0) = 0.75;
uniform float softness : hint_range(0.0, 1.0) = 0.45;

uniform float ovalness : hint_range(0.1, 2.0) = 1.0;

void fragment() {
    vec2 uv = UV - vec2(0.5);

    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

    // Apply both aspect correction AND ovalness control
    uv.y *= aspect * ovalness;

    float dist = length(uv);

    float vignette = smoothstep(radius - softness, radius, dist);

    COLOR = vec4(0.0, 0.0, 0.0, vignette * strength);
}