extends Control

@export var dialogues_1: Array[String]= []
@export var dialogues_2: Array[String] = []
@export var sprite_1: Texture2D
@export var sprite_2: Texture2D
var current_dialogue_index_1: int = 0
var current_dialogue_index_2: int = 0
var current_dialogues: Array[String]
var current_dialogue_index: int = 0
var has_dialogue_ended: bool = false
var turn: int:
	get:
		return turn
	set(value):
		current_dialogues = dialogues_1 if value == 1 else dialogues_2
		current_dialogue_index = current_dialogue_index_1 if value == 1 else current_dialogue_index_2
		turn = value
		
signal dialogue_ended

func _ready() -> void:
	turn = 1
	%Portrait1.texture = sprite_1
	%Portrait2.texture = sprite_2
	update_dialogue_label()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		advance_dialogue()
		
func advance_dialogue() -> void:
	if has_dialogue_ended:
		queue_free()
		get_tree().paused = false
		return
		
	current_dialogue_index += 1
	if current_dialogues[current_dialogue_index].is_empty():
		switch_turns()
	else:			
		update_dialogue_label()
		if current_dialogue_index == len(current_dialogues) - 1:
			end_dialogue()
		

func switch_turns() -> void:
	if turn == 1:
		current_dialogue_index_1 = current_dialogue_index + 1
		%Portrait1.modulate = Color.from_hsv(%Portrait1.modulate.h, %Portrait1.modulate.s, 0.5);
		%Portrait2.modulate = Color.from_hsv(%Portrait2.modulate.h, %Portrait2.modulate.s, 1);
		turn = 2
	else:
		current_dialogue_index_2 = current_dialogue_index +  1
		%Portrait2.modulate = Color.from_hsv(%Portrait2.modulate.h, %Portrait2.modulate.s, 0.5);
		%Portrait1.modulate = Color.from_hsv(%Portrait1.modulate.h, %Portrait1.modulate.s, 1);
		turn = 1
		
	current_dialogue_index -= 1 # Because advance_dialogue() increments the current_dialogue index by 1
								# So this expects that current_dialogue_index is already pointing to the
								# appropriate non-empty dialogue string
	advance_dialogue()
		
func end_dialogue() -> void:
	dialogue_ended.emit()
	has_dialogue_ended = true
	
func update_dialogue_label() -> void:
	%DialogueLabel.text = current_dialogues[current_dialogue_index]
	
func initialize(d1: Dialoguer, d2: Dialoguer) -> void:
	sprite_1 = d1.sprite
	sprite_2 = d2.sprite
	dialogues_1 = d1.dialogues
	dialogues_2 = d2.dialogues
	
