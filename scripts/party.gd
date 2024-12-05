extends Node2D

@export var character_scenes: Array[PackedScene]

var party_members = []

func _ready() -> void:
	instantiate_characters_and_add_to_list(character_scenes, party_members)
	establish_queue(party_members)
	activate_party_member(0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_party_member"):
		active_next_member(get_active_member_index(party_members), party_members)
		
func instantiate_characters_and_add_to_list(character_scenes, party_members) -> void:
	for scene in character_scenes:
		var character = scene.instantiate()
		add_child(character)
		party_members.append(character)
		
func establish_queue(party_members) -> void:
	for i in range(0, len(party_members)):
		if i == len(party_members) - 1:
			party_members[i].next_character = party_members[0]
		else:
			party_members[i].next_character = party_members[i + 1]
			
		party_members[i].character_moved.connect(on_character_moved)
	
func activate_party_member(index: int) -> void:
	for i in range(0, len(party_members)):
		if i == index:
			party_members[index].set_active(true)
		else:
			party_members[i].set_active(false)
	
func on_character_moved(character, old_grid_pos) -> void:
	if not character.next_character.is_active:
		character.next_character.set_grid_pos(old_grid_pos)

func get_active_member_index(party_members) -> int:
	for i in range(0, len(party_members)):
		if party_members[i].is_active:
			return i
	
	return -1
			
func active_next_member(curr_active_index : int, party_members) -> void:
	var new_active_index = (curr_active_index + 1) % len(party_members)
	activate_party_member(new_active_index)
