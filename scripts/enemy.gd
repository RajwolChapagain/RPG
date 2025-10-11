extends Area2D
class_name Enemy

@export var gang: Array[BaseStats]

signal enemy_defeated # Emitted by BattleManager at end of battle

func get_gang() -> Array[BaseStats]:
	return gang
