extends Node
	
const SAVE_DIR = 'user://player_stats/'
var total_npc_count: int = 7
var total_enemy_count: int = 16
var total_essence_count: int = 3

var stats: PlayerStats
	
func _ready() -> void:
	load_stats()
	
func save_stats() -> void:
	var stats_path = SAVE_DIR + "/stats.tres"
	ResourceSaver.save(stats.duplicate(true), stats_path)
	
func load_stats() -> void:
	var stats_path = SAVE_DIR + "/stats.tres"
	if ResourceLoader.exists(stats_path): 
		stats = ResourceLoader.load(stats_path) as PlayerStats
	else: # First time opening game
		if not DirAccess.dir_exists_absolute(SAVE_DIR):
			DirAccess.make_dir_absolute(SAVE_DIR)
		
		stats = PlayerStats.new()
		stats.npcs_interacted.resize(total_npc_count)
		stats.npcs_interacted.fill(false)
		stats.enemies_killed.resize(total_enemy_count)
		stats.enemies_killed.fill(false)
		stats.essences_collected.resize(total_essence_count)
		stats.essences_collected.fill(false)
		ResourceSaver.save(stats, stats_path)

func set_npc_interacted(npc_index: int) -> void:
	if npc_index < 0 or npc_index >= total_npc_count:
		printerr('Invalid npc_index %s when total npc count is %s' % [npc_index, total_npc_count])
		return
		
	if not stats.npcs_interacted[npc_index]:
		Steamworks.increment_stat('npc_count')
		stats.npcs_interacted[npc_index] = true
		save_stats()
		
func set_enemy_killed(enemy_index: int) -> void:
	if enemy_index < 0 or enemy_index >= total_enemy_count:
		printerr('Invalid enemy_index %s when total enemy count is %s' % [enemy_index, total_enemy_count])
		return
		
	if not stats.enemies_killed[enemy_index]:
		Steamworks.increment_stat('enemy_count')
		stats.enemies_killed[enemy_index] = true
		save_stats()
		
func set_essence_collected(essence_index: int) -> void:
	if essence_index < 0 or essence_index >= total_essence_count:
		printerr('Invalid essence_index %s when total essence count is %s' % [essence_index, total_essence_count])
		return
		
	if not stats.essences_collected[essence_index]:
		Steamworks.increment_stat('essence_count')
		stats.essences_collected[essence_index] = true
		save_stats()
		
