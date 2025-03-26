extends Area2D

@export var stats: BaseStats
@export var dialogue_info: Dialoguer
var is_active = true
var grid_pos
var last_grid_pos = grid_pos
var next_character = null
var move_queue = []
	
signal character_moved(character, old_grid_pos)

func _process(_delta: float) -> void:
	take_input()
	process_movement_queue()
	check_and_emit_last_pos()
	
func take_input() -> void:
	if $GridMover.is_moving:
		return

	if not is_active:
		return
		
	if Input.is_action_pressed("move_right"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.RIGHT)
	elif Input.is_action_pressed("move_up"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.UP)
	elif Input.is_action_pressed("move_left"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.LEFT)
	elif Input.is_action_pressed("move_down"):
		move_queue.push_back($GridPositionTracker.get_grid_coord() + Vector2i.DOWN)

func process_movement_queue() -> void:
	if $GridMover.is_moving:
		return
		
	if move_queue.is_empty():
		return
		
	var next_grid_pos = move_queue.front()
	move_queue.remove_at(0)
	if (next_grid_pos == null):
		return
		
	if (next_grid_pos == $GridPositionTracker.get_grid_coord()):
		return
		
	var direction = next_grid_pos - $GridPositionTracker.get_grid_coord()
	
	if direction == Vector2i.RIGHT:
		$GridMover.move_target_right()
		$Sprite2D.play("run_right")
	elif direction == Vector2i.UP:
		$GridMover.move_target_up()
		$Sprite2D.play("run_up")
	elif direction == Vector2i.LEFT:
		$GridMover.move_target_left()
		$Sprite2D.play("run_left")
	elif direction == Vector2i.DOWN:
		$GridMover.move_target_down()
		$Sprite2D.play("run_down")
	else:
		print("Weird direction encountered. Cannot move:")
		print("Current grid pos: ", $GridPositionTracker.get_grid_coord(), " | Next grid pos: ", next_grid_pos)

func check_and_emit_last_pos() -> void:
	if last_grid_pos != $GridPositionTracker.get_grid_coord():
		character_moved.emit(self, last_grid_pos)
		last_grid_pos = $GridPositionTracker.get_grid_coord()
		
func set_active(value: bool) -> void:
	is_active = value
	
	if is_active:
		$Pointer.visible = true
	else:
		$Pointer.visible = false
