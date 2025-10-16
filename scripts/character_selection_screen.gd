extends Control
class_name CharacterSelectionScreen

var selected_indices = []
const COUNT_LABEL_FORMAT: String = '(%s/4)'
signal characters_selected(names)
@export var character_stats: Array[BaseStats]

func _ready() -> void:
	await play_shroud_animation()
	%Buttons.get_child(0).grab_focus()

func select_character(index) -> void:
	selected_indices.append(index)
	if len(selected_indices) == 4:
		finalize_selection()
	%CountLabel.text = COUNT_LABEL_FORMAT % str(len(selected_indices))

func deselect_character(index) -> void:
	selected_indices.remove_at(selected_indices.find(index))
	%CountLabel.text = COUNT_LABEL_FORMAT % str(len(selected_indices))

func _on_button_1_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_character(0)
	else:
		deselect_character(0)

func _on_button_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_character(1)
	else:
		deselect_character(1)

func _on_button_3_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_character(2)
	else:
		deselect_character(2)

func _on_button_4_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_character(3)
	else:
		deselect_character(3)

func _on_button_5_toggled(toggled_on: bool) -> void:
	if toggled_on:
		select_character(4)
	else:
		deselect_character(4)

func finalize_selection() -> void:
	var character_names: Array[String] = []
	for index in selected_indices:
		character_names.append(character_stats[index].name)
	for button in %Buttons.get_children():
		button.release_focus()
		
	slide_stat_card_out()
	make_buttons_invisible()
	%AnimationPlayer.play("label_slide_out")
	await play_character_orient_animation()
	place_rock()
	%AnimationPlayer.play("camera_follow")
	await play_landing_animation()
	%SharpRock.play("flow_blood")
	characters_selected.emit(character_names)
	#queue_free()

func _on_button_1_focus_entered() -> void:
	update_stats_card(0)

func _on_button_2_focus_entered() -> void:
	update_stats_card(1)

func _on_button_3_focus_entered() -> void:
	update_stats_card(2)

func _on_button_4_focus_entered() -> void:
	update_stats_card(3)

func _on_button_5_focus_entered() -> void:
	update_stats_card(4)
	
func update_stats_card(index: int) -> void:
	%StatCard.stats = character_stats[index]
	%StatCard.initialize_ui()
	%StatCard.visible = true

func play_shroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate.r, %Shroud.modulate.g, %Shroud.modulate.b, 0), 2).set_ease(Tween.EaseType.EASE_IN_OUT)
	await tween.finished
	await get_tree().create_timer(3).timeout

func play_character_orient_animation() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	for button in %Buttons.get_children():
		tween.tween_property(button.get_child(0), 'rotation', 0, 2)
	await tween.finished

func slide_stat_card_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%StatCard, 'position', Vector2(%StatCard.position.x + 60, %StatCard.position.y), 1).set_ease(Tween.EASE_OUT)
	await tween.finished

func make_buttons_invisible() -> void:
	for button: Button in %Buttons.get_children():
		button.self_modulate = Color.TRANSPARENT
		 
func play_landing_animation() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	var i = 0
	for button in %Buttons.get_children():
		var final_position = %FinalPositionMarkers.get_child(i).global_position
		tween.tween_property(button.get_child(0), 'global_position', final_position, 2).set_ease(Tween.EASE_IN)
		i += 1
	await tween.finished
	
func place_rock() -> void:
	var unselected_index = range(5).filter(func (x): return x not in selected_indices)[0]
	%SharpRock.global_position = %FinalPositionMarkers.get_child(unselected_index).global_position - Vector2(0, 8)
