extends Node

@export var speed: float
@export var target: Node2D
var target_position_idx = 0
var is_reversed = false
var idle = false
var path_length = 0.0

func _ready() -> void:
	for idx in range(%Path2D.curve.point_count - 1):
		path_length += %Path2D.curve.get_point_position(idx).distance_to(%Path2D.curve.get_point_position(idx + 1))
	
func _process(delta: float) -> void:
	if target == null:
		printerr('Target not set on patroller!')
		return
	
	if idle:
		return

	var epsilon_distance = 5
	# This implementation will fail for large speeds as
	# the position may be incremented by more than epsilon_distance
	# value in a single frame, causing it to not stop on idle points
	if target.global_position.distance_to(%Path2D.to_global(%Path2D.curve.get_point_position(target_position_idx))) < epsilon_distance:
		idle = true
		%IdleTimer.start()
		return
		
	if not is_reversed:
		%PathFollow2D.progress_ratio += delta * speed / path_length
	else:
		%PathFollow2D.progress_ratio -= delta * speed / path_length

	target.global_position = %PathFollow2D.global_position


func _on_idle_timer_timeout() -> void:
	idle = false
	
	if target_position_idx == 0:
		is_reversed = false
		target_position_idx += 1
		return
			
	if target_position_idx == %Path2D.curve.point_count - 1:
		is_reversed = true
		target_position_idx -= 1
		return
		
	if not is_reversed:
		target_position_idx += 1
	else:
		target_position_idx -= 1
