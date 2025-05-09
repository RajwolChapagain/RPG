extends Control

#region: Left
func set_left_dialogue(sprite:Texture2D, text: String) -> void:
	load_left_sprite(sprite)
	brighten_left_sprite()
	dim_right_sprite()
	enable_left_sprite()
	set_dialogue_text(text)
	
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
#endregion

#region: Right
func set_right_dialogue(sprite:Texture2D, text: String) -> void:
	load_right_sprite(sprite)
	brighten_right_sprite()
	dim_left_sprite()
	enable_right_sprite()
	set_dialogue_text(text)
	
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
#endregion

func set_dialogue_text(text: String) -> void:
	%DialogueLabel.text = text
