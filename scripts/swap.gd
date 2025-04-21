extends Area2D
	
var swap_player_index: int = -1
var swap_enemy_index: int = -1
var player_characters_array: Array[Node2D]
var enemy_array: Array[Node2D]

func _ready():
	await get_tree().create_timer(1.5).timeout
	queue_free()

func initialize(player_index: int, player_characters: Array[Node2D], enemy_index: int, enemies: Array[Node2D]) -> void:
	swap_player_index = player_index
	swap_enemy_index = enemy_index
	player_characters_array = player_characters
	enemy_array = enemies
	
func trigger_ability() -> void:
	if not is_initialized():
		print("Error: Did you forget to call initialize()?")
		get_tree().quit(-1)
		
	var player = player_characters_array[swap_player_index]
	var enemy = enemy_array[swap_enemy_index]
	enemy_array[swap_enemy_index] = player
	player_characters_array[swap_player_index] = enemy
	
	var player_pos = player.global_position
	var enemy_pos = enemy.global_position
	player.global_position = enemy_pos
	enemy.global_position = player_pos
	
func is_initialized() -> bool:
	if swap_player_index == -1 or swap_enemy_index == -1 or player_characters_array.is_empty() or enemy_array.is_empty():
		return false
	
	return true
