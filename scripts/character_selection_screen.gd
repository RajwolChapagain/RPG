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
	characters_selected.emit(character_names)
	queue_free()

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
