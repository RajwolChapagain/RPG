extends Area2D

const SPEED: int = 1
const GRID_SIZE: int = 32
var grid_pos = Vector2(0, 0)
var is_moving = true
var is_active = true
var last_grid_pos = grid_pos
var next_character = null
	
signal character_moved(character, old_grid_pos)

func _ready() -> void:
	grid_pos.x = 0

func _process(_delta: float) -> void:
	take_input()
	
	if is_moving:
		is_moving = false
		character_moved.emit(self, last_grid_pos)
		last_grid_pos = grid_pos

func take_input() -> void:
	if is_moving:
		return

	if not is_active:
		return
		
	if Input.is_action_pressed("move_right"):
		$GridMover.move_target_right()
	elif Input.is_action_pressed("move_up"):
		$GridMover.move_target_up()
	elif Input.is_action_pressed("move_left"):
		$GridMover.move_target_left()
	elif Input.is_action_pressed("move_down"):
		$GridMover.move_target_down()

func set_active(value: bool) -> void:
	is_active = value
	
	if is_active:
		$Pointer.visible = true
	else:
		$Pointer.visible = false
		

func set_grid_pos(pos: Vector2):
	grid_pos = pos
