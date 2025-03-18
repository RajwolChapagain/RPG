extends Area2D

@export var DIALOGUE_SCENE: PackedScene = preload("res://scenes/dialogue.tscn")
@export var my_dialogues: Dialoguer
@export var player_dialogues: Dialoguer
 
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_character"):
		player_dialogues.sprite = area.dialogue_info.sprite
		initiate_dialogue()

func initiate_dialogue() -> void:
	var dialogue_scene = DIALOGUE_SCENE.instantiate()
	dialogue_scene.initialize(player_dialogues, my_dialogues)
	get_tree().root.add_child(dialogue_scene)
	get_tree().paused = true
