extends Node

@export var music_dict: Dictionary[StringName, AudioStreamWAV]
@export var loop_interval: float = 8.0

var loudness_tween: Tween = null

func play_music(track_name: String) -> void:
	if track_name in music_dict:
		play_audio_stream(music_dict[track_name])
	else:
		push_error("Error: Track %s not found in Music Manager's dictionary" % track_name)

func play_audio_stream(stream: AudioStreamWAV) -> void:
		if loudness_tween != null and loudness_tween.is_running():
			loudness_tween.stop()
			%AudioStreamPlayer.volume_db = 0.0
		%AudioStreamPlayer.stream = stream
		%AudioStreamPlayer.play()

func seek_stream(time: float) -> void:
	%AudioStreamPlayer.seek(time)
	
func fade_music_out(time: float) -> void:
	loudness_tween = get_tree().create_tween()
	loudness_tween.tween_property(%AudioStreamPlayer, 'volume_db', -80.0, time)
	loudness_tween.tween_callback(func (): %AudioStreamPlayer.stop())
	loudness_tween.tween_callback(func (): %AudioStreamPlayer.volume_db = 0.0)

func _on_audio_stream_player_finished() -> void:
	await get_tree().create_timer(loop_interval).timeout
	%AudioStreamPlayer.play()

func get_current_music_title() -> AudioStreamWAV:
	return %AudioStreamPlayer.stream

func get_current_music_timestamp() -> float:
	return %AudioStreamPlayer.get_playback_position()
