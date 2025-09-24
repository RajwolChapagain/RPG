extends Node

@export var current_level_number: int = 1
@export var levels: Array[PackedScene]
var current_level: Node = null

func _ready() -> void:
	call_deferred('load_level', current_level_number)
	
func load_level(level: int) -> void:
	if current_level != null:
		current_level.queue_free()
		
	current_level = levels[level - 1].instantiate()
	%Party.global_position = current_level.get_node("PartyOriginMarker").global_position
	%Party.reset_player_positions()
	add_child(current_level)
	move_child(current_level, 0)
	current_level.level_completed.connect(on_level_completed)

func load_next_level() -> void:
	current_level_number += 1
	load_level(current_level_number)

func on_level_completed(level_count: int) -> void:
	load_next_level()
