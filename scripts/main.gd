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
	add_child(current_level)
	move_child(current_level, 0)
	%Party.global_position = current_level.get_node("PartyOriginMarker").global_position

func load_next_level() -> void:
	current_level_number += 1
	load_level(current_level_number)
