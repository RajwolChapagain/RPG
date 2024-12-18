extends Node
class_name GridMover

@export var target: Node2D
@export var grid_size: int = 32
@export var speed: float = 0.5

var is_moving = false

func move_target_left():
	if is_moving:
		return
		
	is_moving = true
	var new_pos = target.position - Vector2(grid_size, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(target, "position", new_pos, speed)
	tween.tween_callback(make_moveable)

func move_target_right():		
	if is_moving:
		return
		
	is_moving = true
	var new_pos = target.position + Vector2(grid_size, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(target, "position", new_pos, speed)
	tween.tween_callback(make_moveable)
	
func move_target_up():
	if is_moving:
		return
		
	is_moving = true
	var new_pos = target.position - Vector2(0, grid_size)
	var tween = get_tree().create_tween()
	tween.tween_property(target, "position", new_pos, speed)
	tween.tween_callback(make_moveable)

func move_target_down():
	if is_moving:
		return
		
	is_moving = true
	var new_pos = target.position + Vector2(0, grid_size)
	var tween = get_tree().create_tween()
	tween.tween_property(target, "position", new_pos, speed)
	tween.tween_callback(make_moveable)

func make_moveable():
	is_moving = false
