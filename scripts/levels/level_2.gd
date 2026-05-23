extends Level

@export var guardian_scene: PackedScene
@export_file_path('*.csv') var opening_dialogue

var statue_pending: int = 0
var pending_active: bool = false

func _ready() -> void:
	GameManager.freeze_party()
	MusicManager.play_music('level2')
	await play_unshroud_animation()
	DialogueManager.load_dialogue(opening_dialogue)
	await DialogueManager.dialogue_finished
	GameManager.thaw_party()

func _on_boss_enemy_enemy_defeated() -> void:
	#	ItemDropManager.drop_items([boss_essence])
	pass
	
func _on_level_complete_trigger_area_entered(area: Area2D) -> void:
	if area is Player:
		level_completed.emit(level_number)
	
func play_unshroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate, 0), 1).set_ease(Tween.EASE_OUT)
	await tween.finished

func _on_statue_1_statue_toggled(activated: bool) -> void:
	spawn_guardian(GameManager.get_active_player().global_position) 
	statue_pending = 1
	pending_active = activated

func _on_statue_2_or_3_toggled(activated: bool) -> void:
	spawn_guardian(GameManager.get_active_player().global_position) 
	statue_pending = 2
	pending_active = activated
		
func activate_level_1():
	shake_camera(1.0, 1.0)
	Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(%Layout2, 'modulate', Color(%Layout2.modulate, 0.0), 1.0)
	if %Layout3.modulate.a > 0.0:
		fade_tween.set_parallel(true)
		fade_tween.tween_property(%Layout3, 'modulate', Color(%Layout3.modulate, 0.0), 1.0)
	%WaterLayer1.collision_enabled = true
	%Statue2.is_active = true
	%Statue3.is_active = true
	%Statue2.play_activate_animation()
	%Statue3.play_activate_animation()
	toggle_enemy_mobility(2, true)
	toggle_enemy_mobility(3, true)
	
func activate_level_2():
	shake_camera(1.0, 1.0)
	Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	var fade_tween = get_tree().create_tween()
	if statue_pending == 1:
		fade_tween.tween_property(%Layout2, 'modulate', Color(%Layout2.modulate, 1.0), 1.0)
		%Layout3.modulate = Color(%Layout3.modulate, 0.0)
	else:
		%Layout3.modulate = Color(%Layout2.modulate, 1.0)
		fade_tween.tween_property(%Layout3, 'modulate', Color(%Layout3.modulate, 0.0), 1.0)
	%WaterLayer1.collision_enabled = false
	%WaterLayer2.collision_enabled = true
	%Level3Colliders.set_collision_layer_value(1, false)
	toggle_enemy_mobility(2, false)
	toggle_enemy_mobility(3, true)

func activate_level_3():
	shake_camera(1.0, 1.0)
	Input.start_joy_vibration(0, 1.0, 1.0, 1.0)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(%Layout3, 'modulate', Color(%Layout3.modulate, 1.0), 1.0)
	%WaterLayer1.collision_enabled = false
	%WaterLayer2.collision_enabled = false
	%Level3Colliders.set_collision_layer_value(1, true)
	await fade_tween.finished
	%EelEnemy.visible = true
	toggle_enemy_mobility(3, false)

func toggle_enemy_mobility(level: int, make_mobile: bool) -> void:
	var enemies = %Level2Enemies.get_children() if level == 2 else %Level3Enemies.get_children()
	if make_mobile:
		for enemy: Enemy in enemies:
			enemy.START_PATROL()
			enemy.GET_ANIMATED_SPRITE().speed_scale = 1.0
	else:
		for enemy: Enemy in enemies:
			enemy.STOP_PATROL()
			enemy.PLAY_ANIMATION('flail')
			enemy.GET_ANIMATED_SPRITE().set_frame_and_progress(randi_range(0, 1), randf())
			enemy.GET_ANIMATED_SPRITE().speed_scale = 1.0 + randf_range(-0.2, 0.2)

func spawn_guardian(pos: Vector2) -> void:
	var guardian = guardian_scene.instantiate()
	var random_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() *  160
	var spawn_position = pos + random_offset
	if spawn_position.x > pos.x:
		guardian.get_node('Sprite2D').flip_h = true
	guardian.global_position = spawn_position
	guardian.connect('enemy_defeated', on_guardian_defeated)
	add_child(guardian)
	var tween = get_tree().create_tween()
	tween.tween_property(guardian, 'global_position', pos, 0.3).set_ease(Tween.EASE_OUT)
	guardian.PLAY_ANIMATION('attacking')

func on_guardian_defeated() -> void:
	if statue_pending == 1:
		if pending_active:
			activate_level_1()
			%Statue1.play_activate_animation()
		else:
			activate_level_2()
			%Statue1.play_deactivate_animation()
	else:
		if pending_active:
			activate_level_2()
			%Statue2.play_activate_animation()
			%Statue3.play_activate_animation()
		else:
			activate_level_3()
			%Statue2.play_deactivate_animation()
			%Statue3.play_deactivate_animation()

func shake_camera(magnitude: float, duration: float) -> void:
	await get_tree().process_frame
	GameManager.freeze_party()
	var party_cam = GameManager.get_party_camera()
	var original_pos = party_cam.global_position
	while duration >= 0:
		party_cam.global_position = original_pos + Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude))
		await get_tree().process_frame
		duration -= get_process_delta_time()
	
	party_cam.global_position = original_pos
	GameManager.thaw_party()
