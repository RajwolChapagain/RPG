extends Node

@export var battle_scene: PackedScene
var active_battle_scene: Node

func start_battle(party: Party, enemies: Array[BaseStats]) -> void:
	if active_battle_scene != null:
		return
		
	active_battle_scene = battle_scene.instantiate()
	active_battle_scene.initialize_battle(party.get_all_player_stats(), enemies, party.get_active_member_index())
	get_tree().root.add_child(active_battle_scene)
	freeze_party(party)

func freeze_party(party) -> void:
	party.disable_all_player_movement()
	party.disable_cycling()
