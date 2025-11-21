extends Level

func _on_boss_enemy_enemy_defeated() -> void:
	level_completed.emit(level_number)
