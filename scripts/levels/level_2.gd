extends Level

func _ready() -> void:
	MusicManager.play_music('level2')
	play_unshroud_animation()

func _on_boss_enemy_enemy_defeated() -> void:
	level_completed.emit(level_number)
	
func play_unshroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate, 0), 1).set_ease(Tween.EASE_OUT)
	await tween.finished
