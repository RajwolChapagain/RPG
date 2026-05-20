extends Area2D

@export_file('*.csv') var dialogue_file_path: String
@export var dialogue_start_line_number: int
@export var sprite: Sprite2D

var interactable: bool = false:
	get:
		return interactable
	set(value):
		sprite.material.set_shader_parameter('interactable', value)
		interactable = value

func _process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if area is Player:
			interactable = true
			return
	
	interactable = false
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact') and interactable:
		DialogueManager.load_dialogue(dialogue_file_path, dialogue_start_line_number, self)
