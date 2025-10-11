extends Node
@export var level_number: int = 1

signal level_completed(level_number)

func on_level_completed() -> void:
	level_completed.emit(level_number)

func _on_enemy_enemy_defeated() -> void:
	on_level_completed()
