extends Node

const APP_ID: int = 4578130
var steam_enabled: bool = false

var statistics: Dictionary[String, int] = {
	"npc_count": 0,
	"enemy_count": 0,
	"essence_count": 0
	}

func _ready() -> void:
	initialize_steam()
	if steam_enabled:
		load_steam_stats()
	
func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(APP_ID)

	if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam, shutting down: %s" % initialize_response)
		steam_enabled = false
		return
	
	steam_enabled = true

func set_achievement(achievement_name: String) -> void:
	if not steam_enabled:
		print('Steam is not enabled. Returning from method set_achievement')
		return
		
	var achievement_status: Dictionary = Steam.getAchievement(achievement_name)
	
	if not achievement_status['ret']:
		printerr('No achievement named %s found in Steamworks' % achievement_name)
		return

	Steam.setAchievement(achievement_name)
	store_steam_data()

func set_statistic(this_stat: String, new_value: int = 1) -> void:
	if not steam_enabled:
		print('Steam is not enabled. Returning from method set_statistic')
		return
		
	# Set Steam's version
	if not Steam.setStatInt(this_stat, new_value):
		print("Failed to set stat %s to: %s" % [this_stat, new_value])
		return

	print("Set statistics %s succesfully: %s" % [this_stat, new_value])
	store_steam_data()
	
func increment_stat(stat_name: String) -> void:
	var current_val = Steam.getStatInt(stat_name)
	set_statistic(stat_name, current_val + 1)
	
func load_steam_stats() -> void:
	if not steam_enabled:
		return
		
	for this_stat in statistics.keys():
		var stat_value: int = Steam.getStatInt(this_stat)
		print("Retrieved %s stat: %s" % [this_stat, stat_value])

		# Store the value in our dictionary
		statistics[this_stat] = stat_value
	print("Steam statistics loaded")

func store_steam_data() -> void:
	if not Steam.storeStats():
		print("Failed to store data on Steam")
		return
	
	print("Data successfully sent to Steam")

func reset_statistics() -> void:
	print("Resetting all statistics and achievements for local user")
	if not Steam.resetAllStats(true):
		print("Failed to reset statistics and achievements")
	
func reset_achievement(this_achievement: String) -> void:
	print("Resetting achievement %s" % this_achievement)
	if not Steam.clearAchievement(this_achievement):
		print("Failed to reset achievement: %s" % this_achievement)
	
