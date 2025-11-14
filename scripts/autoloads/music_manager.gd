extends Node

@export var music_dict: Dictionary[StringName, AudioStreamWAV]
@export var loop_interval: float = 8.0

func _ready() -> void:
	play_music('title')

func play_music(track_name: String) -> void:
	if track_name in music_dict:
		%AudioStreamPlayer.stream = music_dict[track_name]
		%AudioStreamPlayer.play()
	else:
		push_error("Error: Track %s not found in Music Manager's dictionary" % track_name)

func _on_audio_stream_player_finished() -> void:
	await get_tree().create_timer(loop_interval).timeout
	%AudioStreamPlayer.play()
