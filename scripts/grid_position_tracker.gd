extends Node2D
class_name GridPositionTracker

@export var grid_size: int = 32
@onready var grid_coord: Vector2i = global_position / grid_size
@onready var position_last_frame: Vector2 = global_position

func _physics_process(delta: float) -> void:
	if global_position.x > position_last_frame.x || global_position.y > position_last_frame.y:
		set_grid_coord(ceil(global_position / grid_size))
	else:
		set_grid_coord(floor(global_position / grid_size))
		
	position_last_frame = global_position
	
func set_grid_coord(new_coord: Vector2i) -> void:
	grid_coord = new_coord
	
func get_grid_coord() -> Vector2i:
	return grid_coord
