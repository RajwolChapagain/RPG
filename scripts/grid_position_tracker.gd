extends Node2D
class_name GridPositionTracker

@export var grid_size: int = 32
@onready var grid_coord: Vector2i = global_position / grid_size

func _physics_process(delta: float) -> void:
	set_grid_coord(ceil(global_position / grid_size))
	
func set_grid_coord(new_coord: Vector2i) -> void:
	grid_coord = new_coord
	
func get_grid_coord() -> Vector2i:
	return grid_coord
