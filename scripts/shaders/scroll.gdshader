shader_type canvas_item;

uniform float scroll_speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec2 scrolled_uv = UV;
    scrolled_uv.y += TIME * scroll_speed;

    COLOR = texture(TEXTURE, scrolled_uv);
}