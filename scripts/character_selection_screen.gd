extends Control
class_name CharacterSelectionScreen

var selected_indices = []
const COUNT_LABEL_FORMAT: String = '(%s/4)'
signal characters_selected(names)

func _ready() -> void:
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
		var stat_card: StatCard = %Buttons.get_child(index).get_child(0)
		character_names.append(stat_card.get_character_name())
	characters_selected.emit(character_names)
	queue_free()
