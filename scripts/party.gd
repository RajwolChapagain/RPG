extends Node2D

@export var character_scenes: Array[PackedScene]

var party_members = []

func _ready() -> void:
	for scene in character_scenes:
		var character = scene.instantiate()
		add_child(character)
		party_members.append(character)

	party_members[0].is_active = true
	party_members[0].character_moved.connect(on_character_moved)
	
func on_character_moved(grid_pos):
	for i in range(1, len(party_members)):
		party_members[i].grid_pos = grid_pos
