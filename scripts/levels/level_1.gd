extends Level

@export var nahas_essence: Item
@export var character_name_to_base_stats: Dictionary[String, BaseStats]
@export_file_path('*.csv') var nahas_awakening_dialogue: String

@export_group('Starting Sequence Dialogues')
@export_file_path('*.csv') var einar_death_dialogue
@export_file_path('*.csv') var josephine_death_dialogue
@export_file_path('*.csv') var lachlan_death_dialogue
@export_file_path('*.csv') var magda_death_dialogue
@export_file_path('*.csv') var rachelle_death_dialogue

func _ready() -> void:
	MusicManager.play_music('level1')
	
	var dead_player = GameManager.get_dead_player_names().pick_random()
	if dead_player == 'Einar':
		DialogueManager.load_dialogue(einar_death_dialogue)
	elif dead_player == 'Josephine':
		DialogueManager.load_dialogue(josephine_death_dialogue)
	elif dead_player == 'Lachlan':
		DialogueManager.load_dialogue(lachlan_death_dialogue)
	elif dead_player == 'Magda':
		DialogueManager.load_dialogue(magda_death_dialogue)
	elif dead_player == 'Rachelle':
		DialogueManager.load_dialogue(rachelle_death_dialogue)
		
	await DialogueManager.dialogue_finished
	drop_unselected_player_essence()
	GameManager.enable_party_camera_smoothing()
	
func drop_unselected_player_essence() -> void:
	var selected_players = GameManager.get_alive_players().map(func (player: Player): return player.stats.name)
	var all_players = ['Rachelle', 'Magda', 'Josephine', 'Lachlan', 'Einar']
	var missing_player = all_players.filter(func(player_name): return player_name not in selected_players)[0]
	GameManager.drop_player_essence(character_name_to_base_stats[missing_player])

func _on_boss_enemy_enemy_defeated() -> void:
	ItemDropManager.drop_items([nahas_essence])

func _on_nahas_awakening_trigger_area_entered(_area: Area2D) -> void:
	%NahasEnemy.PLAY_ANIMATION('awaken')
	%NahasAwakeningTrigger.set_deferred('monitoring', false)
	DialogueManager.load_dialogue(nahas_awakening_dialogue)

func _on_level_complete_trigger_area_entered(_area: Area2D) -> void:
	level_completed.emit(level_number)
