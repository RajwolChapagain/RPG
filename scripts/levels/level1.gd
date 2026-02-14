extends Level

@export var character_name_to_base_stats: Dictionary[String, BaseStats]

func _ready() -> void:
	MusicManager.play_music('level1')
	DialogueManager.load_dialogue('res://assets/dialogues/first_death_dialogue.csv')
	await DialogueManager.dialogue_finished
	drop_unselected_player_essence()
	GameManager.enable_party_camera_smoothing()

func drop_unselected_player_essence() -> void:
	var selected_players = GameManager.get_alive_players().map(func (player: Player): return player.stats.name)
	var all_players = ['Rachelle', 'Magda', 'Josephine', 'Lachlan', 'Einar']
	var missing_player = all_players.filter(func(player_name): return player_name not in selected_players)[0]
	GameManager.drop_player_essence(character_name_to_base_stats[missing_player])

func _on_boss_enemy_enemy_defeated() -> void:
	level_completed.emit(level_number)

func _on_nahas_awakening_trigger_area_entered(_area: Area2D) -> void:
	%NahasEnemy.PLAY_ANIMATION('awaken')
	%NahasAwakeningTrigger.set_deferred('monitoring', false)
