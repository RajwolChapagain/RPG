extends Node

@export var current_level_number: int = 0
@export var character_selection_screen: PackedScene
@export var levels: Array[PackedScene]
@export var party_scene: PackedScene
@export var character_name_to_scene: Dictionary[String, PackedScene]
@export var character_name_to_base_stats: Dictionary[String, BaseStats]

var current_level: Node = null
var party: Party = null

func _ready() -> void:
	call_deferred('load_level', current_level_number)
	
func load_level(level: int) -> void:
	if current_level != null:
		current_level.queue_free()
	
	if level == 0:
		load_character_selection_screen()
		return
		
	current_level = levels[level - 1].instantiate()
	party.global_position = current_level.get_node("PartyOriginMarker").global_position
	party.reset_player_positions()
	add_child(current_level)
	move_child(current_level, 0)
	current_level.level_completed.connect(on_level_completed)

func load_next_level() -> void:
	current_level_number += 1
	load_level(current_level_number)

func on_level_completed(level_count: int) -> void:
	load_next_level()

func load_character_selection_screen() -> void:
	var character_selection = character_selection_screen.instantiate()
	add_child(character_selection)
	character_selection.characters_selected.connect(on_characters_selected)
	
func on_characters_selected(names: Array[String]):
	party = party_scene.instantiate()
	var character_scenes: Array[PackedScene] = []
	for char_name in names:
		character_scenes.append(character_name_to_scene[char_name])
	party.initialize_character_scenes(character_scenes)
	add_child(party)
	%PauseMenu.initialize_inventory()
	load_next_level()
	drop_unselected_player_essence(names)
	
func drop_unselected_player_essence(selected_players: Array[String]) -> void:
	var all_players = ['Rachelle', 'Magda', 'Josephine', 'Lachlan', 'Einar']
	var missing_player = all_players.filter(func(player_name): return player_name not in selected_players)[0]
	ItemDropManager.drop_items([GameManager.crystalize_stat(character_name_to_base_stats[missing_player])])
