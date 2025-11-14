extends Node

@export var music_dict: Dictionary[StringName, AudioStreamWAV]
@export var loop_interval: float = 8.0
	
func play_music(track_name: String) -> void:
	if track_name in music_dict:
		%AudioStreamPlayer.stream = music_dict[track_name]
		%AudioStreamPlayer.play()
	else:
		push_error("Error: Track %s not found in Music Manager's dictionary" % track_name)

func fade_music_out(time: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%AudioStreamPlayer, 'volume_db', -80.0, time)
	tween.tween_callback(func (): %AudioStreamPlayer.stop())
	tween.tween_callback(func (): %AudioStreamPlayer.volume_db = 0.0)

func _on_audio_stream_player_finished() -> void:
	await get_tree().create_timer(loop_interval).timeout
	%AudioStreamPlayer.play()
