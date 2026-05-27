extends Level

@export_file_path('*.csv') var opening_dialogue
@export_file_path('*.csv') var ending_dialogue

func _ready() -> void:
	GameManager.freeze_party()
	MusicManager.play_music('level3')
	await play_unshroud_animation()
	DialogueManager.load_dialogue(opening_dialogue)
	await DialogueManager.dialogue_finished
	GameManager.thaw_party()
		
func play_unshroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate, 0), 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	
func _on_grave_grave_interacted() -> void:
	GameManager.freeze_party()
	%Grave.interactable = false
	%Grave.active = false
	await %Grave.play_activate_animation()
	%NiallEnemy.monitorable = true
	var tween = get_tree().create_tween()
	tween.tween_property(%NiallEnemy, "position", Vector2(%NiallEnemy.position.x, %NiallEnemy.position.y + 64), 0.1)
	%Sky.visible = true
	await get_tree().create_timer(1.0).timeout
	activate_sky()
	
func activate_sky() -> void:
	%Sky.active = true
	%Sky.monitoring = true

func _on_sky_sky_interacted() -> void:
	MusicManager.turn_music_down_dramatically()
	%Sky.active = false
	GameManager.freeze_party()
	GameManager.party.disable_camera_smoothing()
	await get_tree().process_frame
	%TitleShroud.global_position = get_viewport().get_camera_2d().get_screen_center_position()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(%TitleShroud, "modulate", Color(%TitleShroud.modulate, 1.0), 5.0)
	tween.tween_property(GameManager.party, "modulate", Color(Color.WHITE, 0.0), 5.0)
	DialogueManager.load_dialogue(ending_dialogue)
	await DialogueManager.dialogue_finished
	await get_tree().create_timer(4.0).timeout
	level_completed.emit(level_number)
