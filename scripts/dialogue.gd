extends Control

@export var dialogues_1: Array[String]= []
@export var dialogues_2: Array[String] = []
var current_dialogue_1: int = 0
var current_dialogue_2: int = 0
var turn: int = 1

func _ready() -> void:
	%DialogueLabel.text = dialogues[current_dialogue]
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		current_dialogue += 1
		current_dialogue = clamp(current_dialogue, 0, len(dialogues) - 1)
		%DialogueLabel.text = dialogues[current_dialogue]

func update_dialogue_label() -> void:
	var dialogues = dialogues_1 if turn == 1 else dialogues_2
	var index = current_dialogue_1 if turn == 1 else current_dialogue_2
