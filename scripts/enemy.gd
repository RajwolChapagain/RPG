extends Area2D
class_name Enemy

@export var gang: Array[BaseStats]
@export var dropped_items: Array[Item] # Used by battle_manager before queuing this enemy for death
@export var random_drop_item_count: int = 1 # Used by battle_manager before queuing this enemy for death
@export_range(0, 100, 1) var random_dropped_item_rarity_modifier: float = 0 # Used by battle_manager before queuing this enemy for death

signal enemy_defeated # Emitted by BattleManager at end of battle

func get_gang() -> Array[BaseStats]:
	return gang
