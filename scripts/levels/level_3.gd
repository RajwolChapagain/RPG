extends Level

@export_file_path('*.csv') var opening_dialogue

func _ready() -> void:
	GameManager.freeze_party()
	#MusicManager.play_music('level3')
	await play_unshroud_animation()
	DialogueManager.load_dialogue(opening_dialogue)
	await DialogueManager.dialogue_finished
	GameManager.thaw_party()
	
func play_unshroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate, 0), 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	
func _on_grave_grave_interacted() -> void:
	%Grave.interactable = false
	%Grave.active = false
	await %Grave.play_activate_animation()
	%NiallEnemy.monitorable = true
