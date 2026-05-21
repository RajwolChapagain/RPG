class_name Settings extends Resource

@export var fullscreen: bool = true
@export_range(0.0, 1.0, 0.05) var music_level: float = 0.8:
	get:
		return music_level
	set(value):
		music_level = clampf(value, 0.0, 1.0)

func _init(init_fullscreen = true, init_music_level = 0.8) -> void:
	fullscreen = init_fullscreen
	music_level = init_music_level
