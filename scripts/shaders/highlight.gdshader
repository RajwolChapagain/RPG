shader_type canvas_item;
uniform vec4 highlight_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform bool interactable = true;

void vertex() {
}

void fragment() {
	if (COLOR.a > 0.0 && interactable) {
		COLOR =  COLOR + highlight_color;
	}
}