shader_type canvas_item;

uniform vec4 highlight_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform bool interactable = true;
uniform float outline_width = 1.0;

void vertex() {
}

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    COLOR = original_color;

    if (interactable && original_color.a > 0.0) {
        vec2 pixel = TEXTURE_PIXEL_SIZE * outline_width;

        // Sample the 4 cardinal neighbours
        float n = texture(TEXTURE, UV + vec2(0.0,  pixel.y)).a;
        float s = texture(TEXTURE, UV + vec2(0.0, -pixel.y)).a;
        float e = texture(TEXTURE, UV + vec2( pixel.x, 0.0)).a;
        float w = texture(TEXTURE, UV + vec2(-pixel.x, 0.0)).a;

        // If any neighbour is transparent, this pixel is on the outline
        bool on_outline = (n < 0.1 || s < 0.1 || e < 0.1 || w < 0.1);

        if (on_outline) {
            COLOR = original_color + highlight_color;
        }
    }
}