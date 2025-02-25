extends Control

@export var dialogues : Array[String]= []
var current_dialogue: int = 0

func _ready() -> void:
	%DialogueLabel.text = dialogues[current_dialogue]
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		current_dialogue += 1
		current_dialogue = clamp(current_dialogue, 0, len(dialogues) - 1)
		%DialogueLabel.text = dialogues[current_dialogue]
