extends Control

func load_left_sprite(sprite: Texture2D) -> void:
	%Portrait1.texture = sprite
	
func enable_left_sprite() -> void:
	%Portrait1.visible = true

func disable_left_sprite() -> void:
	%Portrait1.visible = false
		
func load_right_sprite(sprite: Texture2D) -> void:
	%Portrait2.texture = sprite

func enable_right_sprite() -> void:
	%Portrait2.visible = true

func disable_right_sprite() -> void:
	%Portrait2.visible = false
