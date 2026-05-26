shader_type canvas_item;

uniform float cloud_speed = 0.05;
uniform float cloud_scale = 3.0;
uniform float cloud_softness = 0.4;
uniform vec4 sky_color_a = vec4(0.4, 0.6, 1.0, 1.0);   // blue sky
uniform vec4 sky_color_b = vec4(0.85, 0.9, 1.0, 1.0);  // light cloud tint
uniform float white_threshold = 0.95;

// --- Noise helpers ---
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float a = fract(sin(dot(i,               vec2(127.1, 311.7))) * 43758.5453);
    float b = fract(sin(dot(i + vec2(1,0),   vec2(127.1, 311.7))) * 43758.5453);
    float c = fract(sin(dot(i + vec2(0,1),   vec2(127.1, 311.7))) * 43758.5453);
    float d = fract(sin(dot(i + vec2(1,1),   vec2(127.1, 311.7))) * 43758.5453);

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fractal brownian motion — layers of noise for cloud-like texture
float fbm(vec2 p) {
    float val = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 5; i++) {
        val += amp * value_noise(p * freq);
        freq *= 2.1;
        amp *= 0.48;
    }
    return val;
}

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    // Detect the white sky region
    bool is_white = original.r >= white_threshold
                 && original.g >= white_threshold
                 && original.b >= white_threshold
                 && original.a > 0.0;

    if (is_white) {
        // Scroll noise over time to simulate drifting clouds
        vec2 uv_scaled = UV * cloud_scale;
        vec2 scroll = vec2(TIME * cloud_speed, TIME * cloud_speed * 0.4);

        float noise = fbm(uv_scaled + scroll);

        // Smooth the noise into cloud shapes
        float cloud = smoothstep(0.5 - cloud_softness, 0.5 + cloud_softness, noise);

        COLOR = mix(sky_color_a, sky_color_b, cloud);
        COLOR.a = original.a;
    } else {
        COLOR = original;
    }
}