extends Area2D

@export_file('*.csv') var dialogue_file_path: String
@export var dialogue_start_line_number: int
@onready var sprite: Sprite2D = %Sprite2D

var interactable: bool = false:
	get:
		return interactable
	set(value):
		sprite.material.set_shader_parameter('interactable', value)
		interactable = value

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('interact') and interactable:
		DialogueManager.load_dialogue(dialogue_file_path, dialogue_start_line_number, self)

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		interactable = true

func _on_area_exited(_area: Area2D) -> void:
	for overlapping_areas in get_overlapping_areas():
		if overlapping_areas is Player:
			return
	
	interactable = false
