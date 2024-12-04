extends CharacterBody2D

const SPEED: int = 1
const GRID_SIZE: int = 32
var grid_pos = Vector2(0, 0)
var is_moving = false
var is_active = false

func _ready() -> void:
	grid_pos.x = 0

func _process(_delta: float) -> void:
	take_input()
	
	if position != grid_pos * GRID_SIZE:
		update_position()
	else:
		is_moving = false
		

func take_input() -> void:
	if is_moving:
		return

	if not is_active:
		return
		
	if Input.is_action_pressed("move_right"):
		grid_pos.x += 1
	elif Input.is_action_pressed("move_up"):
		grid_pos.y -= 1
	elif Input.is_action_pressed("move_left"):
		grid_pos.x -= 1
	elif Input.is_action_pressed("move_down"):
		grid_pos.y += 1
	
# Updates the position to reflect the position in grid_pos
func update_position() -> void:
	var direction: Vector2 = position.direction_to(grid_pos * GRID_SIZE)
	is_moving = true
	velocity = direction * SPEED
	move_and_collide(velocity)

func set_active(value: bool) -> void:
	is_active = value
