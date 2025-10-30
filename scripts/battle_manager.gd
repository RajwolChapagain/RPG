extends Node

@export var battle_scene: PackedScene
var active_battle_scene: Node
var battling_party: Party
var battling_enemy: Enemy

func start_battle(party: Party, enemy: Enemy) -> void:
	battling_enemy = enemy
	var enemies = enemy.get_gang()
	
	if active_battle_scene != null:
		return
		
	battling_party = party
	active_battle_scene = battle_scene.instantiate()
	active_battle_scene.initialize_battle(party.get_all_player_stats(), enemies, party.get_active_member_index())
	active_battle_scene.battle_ended.connect(on_battle_ended)
	get_tree().root.add_child(active_battle_scene)
	freeze_party()

func freeze_party() -> void:
	battling_party.disable_all_player_movement()
	battling_party.disable_cycling()

func thaw_party() -> void:
	battling_party.enable_all_player_movement()
	battling_party.enable_cycling()
	
func on_battle_ended() -> void:
	active_battle_scene.queue_free()
	remove_dead_entities()
	thaw_party()

func remove_dead_entities() -> void:
	remove_dead_players()
	remove_defeated_enemy()
	
func remove_dead_players() -> void:
	battling_party.purge_dead_members()

func remove_defeated_enemy() -> void:
	battling_enemy.queue_free()
	ItemDropManager.drop_random_items(battling_enemy.random_dropped_item_rarity_modifier, battling_enemy.random_drop_item_count)
	ItemDropManager.drop_items(battling_enemy.dropped_items)
	battling_enemy.enemy_defeated.emit()
	battling_enemy = null
