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

func _on_statue_1_statue_toggled(activated: bool) -> void:
	if activated:
		deactivate_level_2()
		%Statue1.play_activate_animation()
	else:
		activate_level_2()
		%Statue1.play_deactivate_animation()

func _on_statue_2_or_3_toggled(activated: bool) -> void:
	if activated:
		deactivate_level_3()
		%Statue2.play_activate_animation()
		%Statue3.play_activate_animation()
	else:
		activate_level_3()
		%Statue2.play_deactivate_animation()
		%Statue3.play_deactivate_animation()
		
func activate_level_2():
	%Layout2.visible = true
	%WaterLayer1.collision_enabled = false

func deactivate_level_2():
	%Layout2.visible = false
	%WaterLayer1.collision_enabled = true

func activate_level_3():
	%Layout3.visible = true
	%WaterLayer2.collision_enabled = false
	%Level3Colliders.set_collision_layer_value(1, true)
	
func deactivate_level_3():
	%Layout3.visible = false
	%WaterLayer2.collision_enabled = true
	%Level3Colliders.set_collision_layer_value(1, false)
