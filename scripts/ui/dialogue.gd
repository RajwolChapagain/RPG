extends Control

var unraveling_line: bool = false
var last_left_character: String = ''
var last_right_character: String = ''

#region: Left
func set_left_dialogue(sprite:Texture2D, character_name: String, text: String) -> void:
	load_left_sprite(sprite)
	brighten_left_sprite()
	brighten_left_name_label()
	dim_right_sprite()
	dim_right_name_label()
	enable_left_sprite(character_name)
	enable_left_tab()
	set_dialogue_text(text)
	load_left_character_name(character_name)
	
func load_left_sprite(sprite: Texture2D) -> void:
	%Portrait1.texture = sprite
	
func load_left_character_name(character_name: String) -> void:
	%LeftNameLabel.text = character_name
	last_left_character = character_name
	
func enable_left_sprite(character_name: String) -> void:
	%Portrait1.visible = true
	if character_name != last_left_character:
		var final_position = %Portrait1.position
		%Portrait1.position = Vector2(%Portrait1.position.x - 15, final_position.y)
		var tween = get_tree().create_tween()
		tween.tween_property(%Portrait1, 'position', final_position, 0.15)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func enable_left_tab() -> void:
	%LeftTab.visible = true
	
func disable_left_sprite() -> void:
	%Portrait1.visible = false
	
func dim_left_sprite() -> void:
	%Portrait1.modulate = Color.from_hsv(%Portrait1.modulate.h, %Portrait1.modulate.s, 0.5);
	
func dim_left_name_label() -> void:
	%LeftNameLabel.modulate = Color.DIM_GRAY
	
func brighten_left_sprite() -> void:
	%Portrait1.modulate = Color.from_hsv(%Portrait1.modulate.h, %Portrait1.modulate.s, 1.0);
	
func brighten_left_name_label() -> void:
	%LeftNameLabel.modulate = Color.WHITE
	
#endregion

#region: Right
func set_right_dialogue(sprite:Texture2D, character_name: String, text: String) -> void:
	load_right_sprite(sprite)
	brighten_right_sprite()
	brighten_right_name_label()
	dim_left_sprite()
	dim_left_name_label()
	enable_right_sprite(character_name)
	enable_right_tab()
	set_dialogue_text(text)
	load_right_character_name(character_name)
	
func load_right_sprite(sprite: Texture2D) -> void:
	%Portrait2.texture = sprite

func load_right_character_name(character_name: String) -> void:
	%RightNameLabel.text = character_name
	last_right_character = character_name
	
func enable_right_sprite(character_name: String) -> void:
	%Portrait2.visible = true
	if character_name != last_right_character:
		var final_position = %Portrait2.position
		%Portrait2.position = Vector2(%Portrait2.position.x + 15, final_position.y)
		var tween = get_tree().create_tween()
		tween.tween_property(%Portrait2, 'position', final_position, 0.15)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func enable_right_tab() -> void:
	%RightTab.visible = true
	
func disable_right_sprite() -> void:
	%Portrait2.visible = false

func dim_right_sprite() -> void:
	%Portrait2.modulate = Color.from_hsv(%Portrait2.modulate.h, %Portrait2.modulate.s, 0.5);

func dim_right_name_label() -> void:
	%RightNameLabel.modulate = Color.DIM_GRAY
	
func brighten_right_sprite() -> void:
	%Portrait2.modulate = Color.from_hsv(%Portrait2.modulate.h, %Portrait2.modulate.s, 1.0);

func brighten_right_name_label() -> void:
	%RightNameLabel.modulate = Color.WHITE
	
#endregion

func set_dialogue_text(text: String) -> void:
	if not unraveling_line:
		unraveling_line = true
		%DialogueLabel.text = ''
		for c in text:
			if !unraveling_line:
				break
			await get_tree().physics_frame
			%DialogueLabel.text += c
		unraveling_line = false
	else:
		unraveling_line = false
		await get_tree().physics_frame
		%DialogueLabel.text = text
		
