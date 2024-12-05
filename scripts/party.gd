extends Node2D

@export var character_scenes: Array[PackedScene]

var party_members = []

func _ready() -> void:
	for scene in character_scenes:
		var character = scene.instantiate()
		add_child(character)
		party_members.append(character)

	for i in range(0, len(party_members)):
		if i == len(party_members) - 1:
			party_members[i].next_character = party_members[0]
		else:
			party_members[i].next_character = party_members[i + 1]
			
		party_members[i].character_moved.connect(on_character_moved)
		
	party_members[0].is_active = true
	
func on_character_moved(character, old_grid_pos):
	if not character.next_character.is_active:
		character.next_character.set_grid_pos(old_grid_pos)
