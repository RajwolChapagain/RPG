extends Control

func load_left_sprite(sprite: Texture2D) -> void:
	%Portrait1.texture = sprite
	
func enable_left_sprite() -> void:
	%Portrait1.visible = true

func disable_left_sprite() -> void:
	%Portrait1.visible = false
	
func dim_left_sprite() -> void:
	%Portrait1.modulate = Color.from_hsv(%Portrait1.modulate.h, %Portrait1.modulate.s, 0.5);
	
func brighten_left_sprite() -> void:
	%Portrait1.modulate = Color.from_hsv(%Portrait1.modulate.h, %Portrait1.modulate.s, 1.0);

func load_right_sprite(sprite: Texture2D) -> void:
	%Portrait2.texture = sprite

func enable_right_sprite() -> void:
	%Portrait2.visible = true

func disable_right_sprite() -> void:
	%Portrait2.visible = false

func dim_right_sprite() -> void:
	%Portrait2.modulate = Color.from_hsv(%Portrait2.modulate.h, %Portrait2.modulate.s, 0.5);

func brighten_right_sprite() -> void:
	%Portrait2.modulate = Color.from_hsv(%Portrait2.modulate.h, %Portrait2.modulate.s, 1.0);
