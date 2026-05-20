extends Node

@export var battle_scene: PackedScene
@export var MAIN_MENU_SCENE: PackedScene
@export_dir var death_dialogues_dir: String
@onready var death_dialogue_path_placeholder: String = death_dialogues_dir + '%s_death.csv'

var active_battle_scene: Node
var battling_party: Party
var battling_enemy: Enemy
var pre_battle_music_stream: AudioStreamWAV
var pre_battle_music_timestamp: float
var is_battle_ongoing: bool = false

func start_battle(party: Party, enemy: Enemy) -> void:
	is_battle_ongoing = true
	battling_enemy = enemy
	var enemies: Array[BaseStats] = []
	for stats: BaseStats in battling_enemy.get_gang():
		enemies.append(stats.duplicate())
	
	if active_battle_scene != null:
		return
		
	battling_party = party
	active_battle_scene = battle_scene.instantiate()
	active_battle_scene.initialize_battle(party.get_all_player_stats(), enemies, party.get_active_member_index())
	active_battle_scene.battle_ended.connect(on_battle_ended)
	active_battle_scene.enemy_hook = enemy.post_defeat_hook
	freeze_party()
	freeze_enemy()
	
	pre_battle_music_stream = MusicManager.get_current_music_title()
	pre_battle_music_timestamp = MusicManager.get_current_music_timestamp()
	MusicManager.fade_music_out(0.8)
	MusicManager.play_music('battle')
	await get_tree().create_timer(0.8).timeout
	battling_party.disable_party_camera()
	%CanvasLayer.add_child(active_battle_scene)
	
func freeze_party() -> void:
	battling_party.disable_all_player_movement()
	battling_party.disable_cycling()

func thaw_party() -> void:
	battling_party.enable_all_player_movement()
	battling_party.enable_cycling()
	
func freeze_enemy() -> void:
	battling_enemy.STOP_PATROL()
	
func on_battle_ended(player_character_stats: Array[BaseStats], battle_won: bool) -> void:
	is_battle_ongoing = false
	active_battle_scene.queue_free()
	if battle_won:
		set_player_hps_post_battle(player_character_stats)
		remove_dead_players()
		battling_party.regroup_party()
		MusicManager.play_audio_stream(pre_battle_music_stream)
		MusicManager.seek_stream(pre_battle_music_timestamp)
		battling_enemy.turn_to_pulp()
		await trigger_death_dialogues(player_character_stats)
		drop_dead_player_essences(player_character_stats)
		remove_defeated_enemy()
		thaw_party()
		battling_party.enable_party_camera()
	else:
		get_tree().call_group('main', 'queue_free')
		get_tree().change_scene_to_packed(MAIN_MENU_SCENE)

func on_pause_menu_dropped_focus() -> void:
	if active_battle_scene != null:
		active_battle_scene.grab_focus_with_attack_button()

func remove_dead_players() -> void:
	battling_party.purge_dead_members()

func remove_defeated_enemy() -> void:
	ItemDropManager.drop_random_items(battling_enemy.random_dropped_item_rarity_modifier, battling_enemy.random_drop_item_count)
	ItemDropManager.drop_items(battling_enemy.dropped_items)
	battling_enemy.enemy_defeated.emit()
	battling_enemy = null

func set_player_hps_post_battle(post_battle_stats: Array[BaseStats]) -> void:
	for stats: BaseStats in post_battle_stats:
		for player: Player in battling_party.get_players():
			if player.stats.name == stats.name:
				player.stats.hp = stats.hp
				
func trigger_death_dialogues(post_battle_stats: Array[BaseStats]) -> void:
	for stats: BaseStats in post_battle_stats:
		if stats.hp == 0:
			DialogueManager.load_dialogue(death_dialogue_path_placeholder % stats.name.to_lower())
			await DialogueManager.dialogue_finished
			
func drop_dead_player_essences(post_battle_stats: Array[BaseStats]) -> void:
	for stats: BaseStats in post_battle_stats:
		if stats.hp == 0:
			GameManager.drop_player_essence(stats)
