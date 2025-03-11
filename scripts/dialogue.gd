extends Control

@export var dialogues_1: Array[String]= []
@export var dialogues_2: Array[String] = []
var current_dialogue_index_1: int = 0
var current_dialogue_index_2: int = 0
var current_dialogues: Array[String]
var current_dialogue_index: int = 0

var turn: int:
	get:
		return turn
	set(value):
		current_dialogues = dialogues_1 if value == 1 else dialogues_2
		current_dialogue_index = current_dialogue_index_1 if value == 1 else current_dialogue_index_2
		turn = value

func _ready() -> void:
	turn = 1
	update_dialogue_label()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		advance_dialogue()
		
func advance_dialogue() -> void:
		current_dialogue_index += 1
		if current_dialogues[current_dialogue_index].is_empty():
			switch_turns()
		update_dialogue_label()

func switch_turns() -> void:
	if turn == 1:
		current_dialogue_index_1 = current_dialogue_index + 1
		turn = 2
	else:
		current_dialogue_index_2 = current_dialogue_index +  1
		turn = 1
		
	current_dialogue_index -= 1
	advance_dialogue()
		
func update_dialogue_label() -> void:
	%DialogueLabel.text = current_dialogues[current_dialogue_index]
