extends Node

@export var battle_scene: PackedScene

func _on_enemy_enemy_encountered_player(enemy: Variant) -> void:
	var player_character_stats = []
	for player_character in get_tree().get_nodes_in_group("player_character"):
		player_character_stats.append(player_character.stats)
	
	var curr_battle_scene = battle_scene.instantiate()
	curr_battle_scene.player_character_stats = player_character_stats
	curr_battle_scene.enemy_stats = [enemy.stats]
	add_child(curr_battle_scene)
