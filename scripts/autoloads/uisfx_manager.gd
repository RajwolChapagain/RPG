extends Node

@export var ui_sfx_dict: Dictionary[StringName, AudioStreamWAV]

func play_sfx(sfx_title: String) -> void:
	if sfx_title in ui_sfx_dict:
		%AudioStreamPlayer.stream = ui_sfx_dict[sfx_title]
		%AudioStreamPlayer.play()
	else:
		push_error("Error: SFX %s not found in UI SFX Manager's dictionary" % sfx_title)
