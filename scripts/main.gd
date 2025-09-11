extends Node

@export var battle_scene: PackedScene
var battle_ongoing = false

func _on_enemy_enemy_encountered_player(enemy: Variant) -> void:
	if battle_ongoing:
		return
		
	battle_ongoing = true
		
	var player_character_stats : Array[BaseStats] = []
	for player_character in get_tree().get_nodes_in_group("player_character"):
		player_character_stats.append(player_character.get_modified_stats())

	var enemy_stats : Array[BaseStats] = []
	enemy_stats.append(enemy.stats)
		
	var curr_battle_scene = battle_scene.instantiate()
	curr_battle_scene.player_character_stats = player_character_stats
	curr_battle_scene.enemy_stats =  enemy_stats
	curr_battle_scene.first_attacker_index = $Party.get_active_member_index()
	curr_battle_scene.battle_ended.connect(on_battle_ended)
	get_tree().root.add_child(curr_battle_scene)

	disable_player_movement()
	
func disable_player_movement() -> void:	
	for player in get_tree().get_nodes_in_group("player_character"):
		player.set_active(false)
		
	# Cycling activates the next player enabling them to move
	$Party.can_cycle = false
	
func enable_player_movement() -> void:
	$Party.can_cycle = true
	$Party.party_members[$Party.get_active_member_index()].set_active(true)

func on_battle_ended() -> void:
	get_tree().root.get_node("BattleScene").queue_free()
	remove_dead_entities()
	enable_player_movement()
	battle_ongoing = false
	
func remove_dead_entities() -> void:
	remove_dead_players()
	remove_dead_enemies()
	
func remove_dead_players() -> void:
	$Party.purge_dead_members()

func remove_dead_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.stats.hp == 0:
			enemy.queue_free()
	
