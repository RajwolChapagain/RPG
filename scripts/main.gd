extends Node

@export var battle_scene: PackedScene

func _on_enemy_enemy_encountered_player(enemy: Variant) -> void:
	var player_character_stats : Array[BaseStats] = []
	for player_character in get_tree().get_nodes_in_group("player_character"):
		player_character_stats.append(player_character.stats)
		
	var enemy_stats : Array[BaseStats] = []
	enemy_stats.append(enemy.stats)
		
	var curr_battle_scene = battle_scene.instantiate()
	curr_battle_scene.player_character_stats = player_character_stats
	curr_battle_scene.enemy_stats =  enemy_stats
	curr_battle_scene.first_attacker_index = $Party.get_active_member_index()
	curr_battle_scene.battle_ended.connect(on_battle_ended)
	add_child(curr_battle_scene)
	
	for player in get_tree().get_nodes_in_group("player_character"):
		player.set_active(false)

func on_battle_ended() -> void:
	get_node("BattleScene").queue_free()
	remove_dead_entities()
	
func remove_dead_entities() -> void:
	remove_dead_players()
	remove_dead_enemies()
	
func remove_dead_players() -> void:
	$Party.purge_dead_members()

func remove_dead_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.stats.hp == 0:
			enemy.queue_free()
	
