extends Area2D
class_name Enemy

@export var gang: Array[BaseStats]
@export var dropped_items: Array[Item] # Used by battle_manager before queuing this enemy for death
@export var random_drop_item_count: int = 1 # Used by battle_manager before queuing this enemy for death
@export_range(0, 100, 1) var random_dropped_item_rarity_modifier: float = 0 # Used by battle_manager before queuing this enemy for death

@warning_ignore("unused_signal")
signal enemy_defeated # Emitted by BattleManager at end of battle

func get_gang() -> Array[BaseStats]:
	return gang

func turn_to_pulp() -> void:
	%Sprite2D.visible = false
	%PulpSprite.frame = randi_range(0, 3)
	%CollisionShape2D.disabled = true
	%PulpSprite.visible = true

func STOP_PATROL() -> void:
	for child in get_children():
		if child is Patroller:
			child.STOP_PATROL()
