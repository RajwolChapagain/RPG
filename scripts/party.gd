extends Node2D
class_name Party

@export var character_scenes: Array[PackedScene]

var party_members: Array[Player]
var can_cycle = true

func _ready() -> void:
	instantiate_characters_and_add_to_list()
	establish_queue()
	activate_party_member(0)
	connect_player_signals()
	GameManager.set_party(self)
	EffectsManager.set_camera(%Camera2D)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_party_member"):
		if can_cycle:
			activate_next_member()
		
func initialize_character_scenes(scenes: Array[PackedScene]) -> void:
	character_scenes = scenes
	
func instantiate_characters_and_add_to_list() -> void:
	for scene in character_scenes:
		var character = scene.instantiate()
		add_child(character)
		party_members.append(character)
		
func establish_queue() -> void:
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
			%Camera2D.reparent(party_members[index])
			%Camera2D.position = Vector2.ZERO
		else:
			party_members[i].set_active(false)
	
func on_character_moved(character, old_grid_pos) -> void:
	if not character.next_character.is_active:
		character.next_character.move_queue.push_back(old_grid_pos)

func get_active_member_index() -> int:
	for i in range(0, len(party_members)):
		if party_members[i].is_active:
			return i
	
	return -1
			
func activate_next_member() -> void:
	var new_active_index = (get_active_member_index() + 1) % len(party_members)
	activate_party_member(new_active_index)
	
func purge_dead_members() -> void:
	var new_members: Array[Player] = []
	for member in party_members:
		if member.stats.hp == 0:
			GameManager.increase_available_inventory_slots()
			GameManager.remove_character_inventory(member.stats.name)
			GameManager.drop_player_essence(member.stats)
			member.queue_free()
		else:
			new_members.append(member)

	party_members = new_members
	reestablish_queue()
	
func reestablish_queue() -> void:
	for member in party_members:
		member.disconnect("character_moved", on_character_moved)

	establish_queue()
	activate_party_member(0)

func get_players() -> Array[Player]:
	return party_members

func on_player_encountered_enemy(enemy) -> void:
	BattleManager.start_battle(self, enemy)
	
func get_all_player_stats() -> Array[BaseStats]:
	var stats: Array[BaseStats]
	for player: Player in party_members:
		stats.append(player.get_modified_stats())
	return stats

func connect_player_signals() -> void:
	for player: Player in party_members:
		player.enemy_encountered.connect(on_player_encountered_enemy)

func disable_all_player_movement() -> void:
	%Camera2D.enabled = false
	party_members[get_active_member_index()].set_active(false)
	
func disable_cycling() -> void:
	can_cycle = false

func enable_all_player_movement() -> void:
	party_members[0].set_active(true)
	%Camera2D.enabled = true

func enable_cycling() -> void:
	can_cycle = true

func reset_player_positions() -> void:
	for player in party_members:
		player.position = Vector2.ZERO
