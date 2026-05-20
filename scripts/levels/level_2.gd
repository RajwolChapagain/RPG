extends Level

func _ready() -> void:
	MusicManager.play_music('level2')

func _on_boss_enemy_enemy_defeated() -> void:
	level_completed.emit(level_number)
