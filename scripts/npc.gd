extends Area2D

@export_file('*.csv') var dialogue_file_path: String
@export var dialogue_start_line_number: int

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_character"):
		DialogueManager.load_dialogue(dialogue_file_path, dialogue_start_line_number)
